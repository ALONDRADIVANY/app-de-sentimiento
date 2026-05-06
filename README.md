# SEC Sentiment Analyzer

Análisis de sentimiento de documentos SEC usando inteligencia artificial local. Esta aplicación permite cargar archivos SEC (en formato PDF o TXT) y analizar automáticamente el sentimiento de cada sección del documento utilizando técnicas de procesamiento de lenguaje natural.

## Características Principales

- **Carga de Documentos:** Soporta archivos PDF y TXT de hasta 50MB
- **Análisis Automático:** Extrae automáticamente secciones comunes de documentos SEC
- **Análisis de Sentimiento:** Clasifica el sentimiento de cada sección como positivo, negativo o neutral
- **Sentimiento General:** Calcula un sentimiento agregado para todo el documento
- **100% Local:** Todo el procesamiento ocurre en tu navegador, sin enviar datos a servidores externos
- **Interfaz Moderna:** Diseño limpio y responsivo con React + Tailwind CSS

## Requisitos

- Node.js 18+ y npm/pnpm
- Navegador moderno (Chrome, Firefox, Safari, Edge)

## Instalación y Uso

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/sec-sentiment-analyzer.git
cd sec-sentiment-analyzer
```

### 2. Instalar Dependencias

```bash
npm install
# o si usas pnpm
pnpm install
```

### 3. Ejecutar en Modo Desarrollo

```bash
npm run dev
# o
pnpm dev
```

La aplicación estará disponible en `http://localhost:5173` (cliente) y el servidor en `http://localhost:3001`.

### 4. Compilar para Producción

```bash
npm run build
npm start
```

## Estructura del Proyecto

```
sec-sentiment-analyzer/
├── client/                    # Aplicación React
│   ├── src/
│   │   ├── components/       # Componentes reutilizables
│   │   │   ├── FileUpload.tsx
│   │   │   └── SentimentResults.tsx
│   │   ├── pages/            # Páginas de la aplicación
│   │   │   └── Home.tsx
│   │   ├── lib/              # Utilidades
│   │   │   └── trpc.ts
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   └── index.css
│   └── index.html
├── server/                    # Backend Express + tRPC
│   ├── index.ts              # Servidor principal
│   ├── routers.ts            # Rutas tRPC
│   ├── context.ts            # Contexto de tRPC
│   ├── trpc.ts               # Configuración de tRPC
│   └── sentimentAnalyzer.ts  # Lógica de análisis
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## Cómo Funciona

### Flujo de Análisis

1. **Carga de Archivo:** El usuario selecciona o arrastra un archivo PDF o TXT
2. **Extracción de Texto:** El archivo se procesa para extraer el texto completo
3. **División en Secciones:** El texto se divide automáticamente en secciones (Business Overview, Risk Factors, etc.)
4. **Análisis de Sentimiento:** Cada sección se analiza para determinar su sentimiento
5. **Agregación:** Se calcula un sentimiento general basado en todas las secciones

### Análisis de Sentimiento

El análisis de sentimiento utiliza:

- **Análisis de Palabras Clave:** Identifica palabras positivas (growth, profit, success) y negativas (loss, risk, decline)
- **Puntuación:** Calcula una puntuación entre 0 (muy negativo) y 1 (muy positivo)
- **Confianza:** Proporciona un nivel de confianza en el análisis

### Secciones Detectadas

La aplicación reconoce automáticamente las siguientes secciones:

- Business Overview / Descripción del Negocio
- Risk Factors / Factores de Riesgo
- Financial Performance / Desempeño Financiero
- Management Discussion / Discusión y Análisis
- Legal Proceedings / Procedimientos Legales

## Interfaz de Usuario

### Pantalla Principal

La aplicación presenta una interfaz intuitiva con:

- **Zona de Carga:** Área de arrastrar y soltar para cargar archivos
- **Información:** Detalles sobre formatos soportados y características
- **Resultados:** Vista detallada del análisis con sentimiento general y por sección

### Visualización de Resultados

Cada sección muestra:

- **Sentimiento:** Clasificación (Positivo/Negativo/Neutral) con icono
- **Puntuación:** Porcentaje de sentimiento (0-100%)
- **Confianza:** Nivel de confianza del análisis
- **Razonamiento:** Explicación breve del análisis
- **Contenido:** Primeros 300 caracteres de la sección

## Tecnologías Utilizadas

| Tecnología | Propósito |
|---|---|
| **React 19** | Framework de interfaz de usuario |
| **TypeScript** | Tipado estático para JavaScript |
| **Tailwind CSS 4** | Estilos y diseño responsivo |
| **Express 4** | Servidor backend |
| **tRPC 11** | RPC type-safe entre cliente y servidor |
| **PDF.js** | Extracción de texto de PDFs |
| **Vite 7** | Bundler y servidor de desarrollo |
| **Sonner** | Notificaciones toast |
| **Lucide React** | Iconos |

## Ejemplo de Análisis

### Entrada
```
Business Overview: Our company has experienced significant growth in the past year. 
We have successfully expanded into new markets and increased our market share.

Risk Factors: However, we face challenges from increased competition and regulatory changes.
These risks could negatively impact our future performance.
```

### Salida
```
Sentimiento General: Neutral (52%)

Secciones:
1. Business Overview: Positivo (75%)
   - Palabras clave positivas detectadas: growth, successfully, expanded

2. Risk Factors: Negativo (35%)
   - Palabras clave negativas detectadas: challenges, risks, negatively
```

## Privacidad y Seguridad

- **Sin Almacenamiento:** Los archivos no se almacenan en el servidor
- **Procesamiento Local:** Todo el análisis ocurre en el navegador del usuario
- **Sin Conexión Externa:** No se envían datos a servicios de terceros
- **Código Abierto:** Puedes revisar el código fuente para verificar la seguridad

## Licencia

MIT License - Ver archivo LICENSE para más detalles

## Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Haz un fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Contacto

Para preguntas o sugerencias, por favor abre un issue en el repositorio.

## Referencias

Este proyecto fue inspirado en técnicas de análisis de sentimiento aplicadas a documentos financieros, como se describe en análisis de impacto empresarial usando modelos de texto.

---

**Nota:** Esta aplicación utiliza análisis de palabras clave para determinar el sentimiento. Para resultados más precisos en producción, se podría integrar un modelo de lenguaje más avanzado como Qwen2-0.5B Instruct u otros modelos especializados en análisis financiero.
