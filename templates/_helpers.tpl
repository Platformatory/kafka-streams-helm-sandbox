{{- define "imagePushSecret" }}
{{- printf "{\"auths\":{\"%s\":{\"auth\":\"%s\"}}}" .Values.streams.build.pushSecretData.registry (printf "%s:%s" .Values.streams.build.pushSecretData.username .Values.streams.build.pushSecretData.password | b64enc) | b64enc }}
{{- end }}