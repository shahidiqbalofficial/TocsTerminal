# Dockerfile
FROM nginx:latest

COPY myfile.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
