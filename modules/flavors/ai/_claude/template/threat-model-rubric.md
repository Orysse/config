# Rubric : threat model
Le design doc doit expliciter, sans ambiguïté :
- Frontières de confiance et données qui les traversent
- Toute entrée non fiable : origine, validation, encodage
- Authentification et autorisation : qui peut faire quoi, où c'est vérifié
- Secrets : où ils vivent, qui y accède, rotation
- Journalisation : ce qui est loggé, ce qui ne doit jamais l'être
- Dépendances nouvelles et leur justification
- Comportement en cas d'échec (fail-open ou fail-closed, et pourquoi)
- Abus prévisibles (rate limiting, énumération, rejeu)
Toute réponse manquante ou vague = NO-GO.
