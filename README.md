# Chat App

Documentation URL : http://localhost:3000/api-docs

## Getting the project running on local machine using Docker:
- Copy example.env to a new file .env
- Run `docker-compose up`
- Create elastic search index `docker-compose run web bin/rake elastic_search:create_messages_index`

