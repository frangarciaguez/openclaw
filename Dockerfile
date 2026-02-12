FROM node:22-bookworm

# 1. Herramientas necesarias
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apt-get update && apt-get install -y git curl python3 make g++ && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Clonar y Compilar (Esto es lo que garantiza que el binario EXISTA)
# Clonamos directamente para asegurar que tenemos el código fuente completo
RUN git clone https://github.com/openclaw/openclaw.git .

# 3. Construcción del proyecto
RUN pnpm install --frozen-lockfile
RUN pnpm build
RUN pnpm ui:build

# 4. Configuración de entorno
ENV NODE_ENV=production
ENV OPENCLAW_PREFER_PNPM=1

# Permisos para el usuario node
RUN chown -R node:node /app
USER node

# 5. ARRANQUE: Forzamos el bind a 'lan' para que Dokploy lo vea
EXPOSE 18789
CMD ["node", "dist/index.js", "gateway", "--allow-unconfigured", "--bind", "lan", "--port", "18789"]
