#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'time'

class WebScraper
  attr_reader :results

  def initialize
    @results = []
    @timeout = 10
  end

  def fetch_page(url)
    uri = URI.parse(url)
    
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.read_timeout = @timeout
      http.open_timeout = @timeout

      request = Net::HTTP::Get.new(uri.request_uri)
      request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'

      response = http.request(request)

      case response.code.to_i
      when 200
        puts "✓ Página carregada com sucesso (#{response.code})"
        response.body
      when 404
        puts "✗ Página não encontrada (404)"
        nil
      when 403
        puts "✗ Acesso proibido (403)"
        nil
      else
        puts "✗ Erro HTTP: #{response.code}"
        nil
      end
    rescue Timeout::Error
      puts "✗ Timeout ao conectar (#{@timeout}s)"
      nil
    rescue SocketError => e
      puts "✗ Erro de conexão: #{e.message}"
      nil
    rescue => e
      puts "✗ Erro inesperado: #{e.message}"
      nil
    end
  end

  def extract_links(html, base_url)
    links = []
    
    # Regex simples para encontrar links
    html.scan(/<a\s+href=["']([^"']+)["']/) do |match|
      url = match[0]
      
      # Converter URLs relativas em absolutas
      if url.start_with?('http')
        links << url
      elsif url.start_with?('/')
        uri = URI.parse(base_url)
        links << "#{uri.scheme}://#{uri.host}#{url}"
      end
    end

    links.uniq
  end

  def extract_headings(html)
    headings = []
    
    html.scan(/<h[1-6][^>]*>([^<]+)<\/h[1-6]>/i) do |match|
      headings << match[0].strip
    end

    headings
  end

  def extract_paragraphs(html, limit = 5)
    paragraphs = []
    
    html.scan(/<p[^>]*>([^<]+)<\/p>/i) do |match|
      text = match[0].strip.gsub(/\s+/, ' ')
      paragraphs << text if text.length > 20
      break if paragraphs.length >= limit
    end

    paragraphs
  end

  def extract_metadata(html, url)
    metadata = {
      url: url,
      title: extract_title(html),
      description: extract_description(html),
      keywords: extract_keywords(html),
      fetched_at: Time.now.iso8601
    }

    metadata
  end

  private

  def extract_title(html)
    match = html.match(/<title[^>]*>([^<]+)<\/title>/i)
    match ? match[1].strip : 'N/A'
  end

  def extract_description(html)
    match = html.match(/<meta\s+name=["']description["']\s+content=["']([^"']+)["']/i)
    match ? match[1].strip : 'N/A'
  end

  def extract_keywords(html)
    match = html.match(/<meta\s+name=["']keywords["']\s+content=["']([^"']+)["']/i)
    match ? match[1].split(',').map(&:strip) : []
  end

  def save_json(filename)
    File.write(filename, JSON.pretty_generate(@results))
    puts "✓ Dados salvos em #{filename}"
  end

  def save_csv(filename)
    return if @results.empty?

    CSV.open(filename, 'w') do |csv|
      csv << @results[0].keys
      @results.each { |row| csv << row.values }
    end

    puts "✓ Dados salvos em #{filename}"
  end

  def show_menu
    puts "\n" + "=".repeat(50)
    puts "🕷️  WEB SCRAPER"
    puts "=".repeat(50)
    puts "1. Scrape de uma URL"
    puts "2. Scrape de múltiplas URLs"
    puts "3. Salvar resultados (JSON)"
    puts "4. Salvar resultados (CSV)"
    puts "5. Ver resultados"
    puts "6. Limpar resultados"
    puts "7. Sair"
    puts "=".repeat(50)
  end

  def scrape_single_url
    print "\nDigite a URL: "
    url = gets.chomp.strip

    return if url.empty?

    puts "\nOpcões de extração:"
    puts "1. Metadados (título, descrição, keywords)"
    puts "2. Links"
    puts "3. Títulos (headings)"
    puts "4. Parágrafos"
    puts "5. Tudo"

    print "Escolha (1-5): "
    choice = gets.chomp.strip

    html = fetch_page(url)
    return unless html

    result = { url: url }

    case choice
    when '1'
      result.merge!(extract_metadata(html, url))
    when '2'
      result[:links] = extract_links(html, url)
    when '3'
      result[:headings] = extract_headings(html)
    when '4'
      result[:paragraphs] = extract_paragraphs(html)
    when '5'
      result.merge!(extract_metadata(html, url))
      result[:links] = extract_links(html, url)
      result[:headings] = extract_headings(html)
      result[:paragraphs] = extract_paragraphs(html)
    else
      puts "✗ Opção inválida!"
      return
    end

    @results << result
    puts "✓ Dados extraídos com sucesso!"
  end

  def scrape_multiple_urls
    print "\nQuantas URLs deseja scrape? "
    count = gets.chomp.to_i

    count.times do |i|
      print "\n[#{i + 1}/#{count}] Digite a URL: "
      url = gets.chomp.strip
      next if url.empty?

      html = fetch_page(url)
      next unless html

      result = extract_metadata(html, url)
      @results << result
    end

    puts "\n✓ Scrape concluído!"
  end

  def run
    loop do
      show_menu
      print "Escolha uma opção: "
      choice = gets.chomp.strip

      case choice
      when '1'
        scrape_single_url
      when '2'
        scrape_multiple_urls
      when '3'
        save_json('results.json') unless @results.empty?
      when '4'
        save_csv('results.csv') unless @results.empty?
      when '5'
        if @results.empty?
          puts "\n✗ Nenhum resultado disponível"
        else
          puts "\n" + JSON.pretty_generate(@results)
        end
      when '6'
        @results.clear
        puts "✓ Resultados limpos!"
      when '7'
        puts "\nAté logo!"
        break
      else
        puts "✗ Opção inválida!"
      end
    end
  end
end

if __FILE__ == $0
  scraper = WebScraper.new
  scraper.run
end
