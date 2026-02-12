FROM node:22-bookworm

# 1. Instalamos Bun y PNPM (necesarios para OpenClaw)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"
RUN npm install -g pnpm

WORKDIR /app

# 2. Descargamos el código oficial (Aseguramos tener el binario real)
# Nota: Aquí clonamos la versión estable de 2026
RUN git clone https://github.com/openclaw/openclaw.git .

# 3. Instalación y Compilación (Esto es lo que faltaba)
RUN pnpm install --frozen-lockfile
RUN pnpm build
RUN pnpm ui:build

ENV NODE_ENV=production
ENV OPENCLAW_PREFER_PNPM=1

# 4. Ajuste de permisos para el usuario 'node'
RUN chown -R node:node /app
USER node

# 5. EL FIX DEL GATEWAY: Forzamos el bind a 'lan' para Dokploy
EXPOSE 18789
CMD ["node", "dist/index.js", "gateway", "--allow-unconfigured", "--bind", "lan", "--port", "18789"]
