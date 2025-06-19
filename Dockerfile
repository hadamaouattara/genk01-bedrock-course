# Image de base Python
FROM python:3.12-slim

# Variables d'environnement
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PATH="/home/appuser/.local/bin:$PATH"

# Installation des dépendances système et Node.js en une seule couche
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs \
        npm \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*

# Création d'un utilisateur non-root pour la sécurité
RUN useradd -m -u 1000 appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

# Basculer vers l'utilisateur non-root
USER appuser

# Définir le répertoire de travail
WORKDIR /app

# Installation d'AWS CLI via pip (plus propre que apt)
RUN pip install --user --no-cache-dir awscli

# Copier et installer les dépendances Python d'abord (pour le cache Docker)
COPY --chown=appuser:appuser requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Copier le reste du code de l'application
COPY --chown=appuser:appuser . .

# Exposer le port si nécessaire (à adapter selon votre app)
# EXPOSE 8000

# Santé check optionnel
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#   CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

# Commande par défaut
CMD ["bash"]