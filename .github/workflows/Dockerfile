### Dockerfile for: tillawy/keycloak-github-actions
##
## To build & push
# docker buildx build . --platform linux/amd64 -t tillawy/keycloak-github-actions:25.0.1
# docker push tillawy/keycloak-github-actions:25.0.1
#
## To Run Locally
# docker run \
#        --rm \
#        -p 8080:8080 \
#        -e KEYCLOAK_ADMIN="admin" \
#        -e KEYCLOAK_ADMIN_PASSWORD="admin" \
#        -e KC_HOSTNAME="http://localhost:8080" \
#        -e KC_HOSTNAME_ADMIN="http://localhost:8080" \
#        -e KC_HTTP_ENABLED="true" \
#        -e KC_DB="dev-file" \
#        tillawy/keycloak-github-actions:25.0.1

FROM quay.io/keycloak/keycloak:25.0.1

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

CMD ["start-dev", "--hostname=http://localhost:8080" , "--hostname-admin=http://localhost:8080" , "--http-enabled=true", "--verbose"]

