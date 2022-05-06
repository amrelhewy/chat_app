# Chat App

Documentation URL : http://localhost:3000/api-docs OR https://api.hewi.ml/api-docs

## Note
The search endpoint is in the docs as the messages GET with a query param

## Getting the project running on local machine using Docker:
- Copy example.env to a new file .env
- Run `docker-compose up`
- Create elastic search index `docker-compose run web bin/rake elastic_search:create_messages_index`, This is because i altered a bit in it

## To run specs
- Run `docker-compose run web bin/rspec`

## Note
Probably it's out of the task scope but i implemented a small fallback system if redis was down in the messages and chat creation, i know its obviously ALOT slower than the normal approach but i guaranteed some sort of reliabillity and i would love to know your opinion about it as i learn from you guys alot!

## Extra
I've also added a CI pipeline using jenkins (i was learning jenkins so thought i'd apply on this task), also out of scope but if interested here's the link: `https://jenkins.hewi.ml`
username: admin
password: if interested send an email to amrelhewi@gmail.com, risky adding it here really :D
