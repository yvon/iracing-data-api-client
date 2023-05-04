1. Write an `.env` file with IRACING_EMAIL and IRACING_PASSWORD variables
2. Build and run the docker container

```
docker build -t iracing_stats .
docker run -d --name iracing_stats_container -p 4000:4000 --env-file .env iracing_stats
```
