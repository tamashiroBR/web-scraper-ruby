# 🕷️ Web Scraper (Ruby)

Um script utilitário em Ruby para extrair informações de páginas web, incluindo metadados, links e conteúdo textual, sem depender de gems externas complexas.

## 🚀 Funcionalidades

- Scrape de URL única ou múltiplas URLs em lote
- Extração de metadados (Title, Description, Keywords)
- Extração de links (convertendo URLs relativas para absolutas)
- Extração de títulos (h1-h6) e parágrafos
- Exportação de resultados para JSON e CSV
- Tratamento robusto de erros HTTP e timeouts

## 🛠️ Tecnologias

- Ruby
- Módulos padrão: `net/http`, `uri`, `json`, `csv`
- Expressões regulares (Regex) para parsing HTML

## 📦 Como executar

1. Certifique-se de ter o Ruby instalado
2. Clone o repositório
3. Navegue até o diretório do projeto:
   ```bash
   cd 8-web-scraper-ruby
   ```
4. Dê permissão de execução (opcional no Linux/Mac):
   ```bash
   chmod +x scraper.rb
   ```
5. Execute o script:
   ```bash
   ruby scraper.rb
   ```

## ⚠️ Aviso Legal

Este scraper é para fins educacionais. Sempre respeite o `robots.txt` dos sites e os Termos de Serviço ao extrair dados. Não faça requisições excessivas que possam sobrecarregar os servidores alvo.

## 📄 Licença

Este projeto está sob a licença MIT.
