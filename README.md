```bash
docker build -t 'rc:dev' .
# docker save -o rc.tar rc:dev
# docker load rc.tar
docker run -it -p 3000:3000 rc:dev bash
> meteor --allow-superuser npm run debug
```
