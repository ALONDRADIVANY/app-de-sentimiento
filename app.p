"""
app.py
======
Interfaz web de la aplicación de traducción Qwen2-0.5B construida con Streamlit.

Características:
  - Carga del modelo con caché de sesión (se carga una sola vez)
  - Selección de idioma destino desde un menú desplegable
  - Casos de prueba predefinidos con un clic
  - Historial de traducciones en la sesión actual
  - Métricas de rendimiento (tiempo de inferencia, dispositivo)
  - Manejo robusto de errores con mensajes claros al usuario

Uso:
    streamlit run app.py
"""

import sys
import os

# Añadir el directorio raíz al path para importar src
sys.path.insert(0, os.path.dirname(__file__))

import streamlit as st
from src.translator import Qwen2Translator, SUPPORTED_LANGUAGES

# ---------------------------------------------------------------------------
# Configuración de la página
# ---------------------------------------------------------------------------
st.set_page_config(
    page_title="Qwen2 Translator",
    page_icon="🌐",
    layout="centered",
    initial_sidebar_state="expanded",
)

# ---------------------------------------------------------------------------
# Estilos CSS personalizados
# ---------------------------------------------------------------------------
st.markdown(
    """
    <style>
        .main-title {
            font-size: 2.4rem;
            font-weight: 700;
            text-align: center;
            color: #1a1a2e;
            margin-bottom: 0.2rem;
        }
        .subtitle {
            text-align: center;
            color: #555;
            font-size: 1rem;
            margin-bottom: 1.5rem;
        }
        .translation-box {
            background: #f0f7ff;
            border-left: 4px solid #4a90d9;
            border-radius: 8px;
            padding: 1rem 1.2rem;
            font-size: 1.15rem;
            color: #1a1a2e;
            margin-top: 0.5rem;
        }
        .metric-row {
            display: flex;
            gap: 1rem;
            margin-top: 0.5rem;
        }
        .history-item {
            background: #fafafa;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            padding: 0.6rem 0.9rem;
            margin-bottom: 0.4rem;
            font-size: 0.9rem;
        }
        .badge {
            display: inline-block;
            background: #4a90d9;
            color: white;
            border-radius: 12px;
            padding: 0.15rem 0.6rem;
            font-size: 0.78rem;
            font-weight: 600;
            margin-right: 0.4rem;
        }
    </style>
    """,
    unsafe_allow_html=True,
)

# ---------------------------------------------------------------------------
# Carga del modelo con caché de sesión
# ---------------------------------------------------------------------------
@st.cache_resource(show_spinner=False)
def load_translator() -> Qwen2Translator:
    """
    Carga el modelo Qwen2-0.5B una sola vez y lo almacena en caché.
    Streamlit reutiliza la instancia entre reruns sin recargar el modelo.
    """
    return Qwen2Translator(
        temperature=0.3,
        max_new_tokens=256,
    )


# ---------------------------------------------------------------------------
# Barra lateral — configuración y casos de prueba
# ---------------------------------------------------------------------------
with st.sidebar:
    st.image(
        "https://huggingface.co/front/assets/huggingface_logo-noborder.svg",
        width=48,
    )
    st.markdown("## ⚙️ Configuración")

    # Selección de idioma destino
    target_lang_label = st.selectbox(
        "Idioma destino",
        options=list(SUPPORTED_LANGUAGES.keys()),
        index=0,  # Español por defecto
        help="Selecciona el idioma al que deseas traducir el texto.",
    )
    target_lang_code = SUPPORTED_LANGUAGES[target_lang_label]

    # Parámetros avanzados (expansible)
    with st.expander("Parámetros avanzados"):
        temperature = st.slider(
            "Temperatura",
            min_value=0.0,
            max_value=1.0,
            value=0.3,
            step=0.05,
            help="Valores bajos → traducciones más deterministas. "
                 "Valores altos → mayor variabilidad.",
        )
        max_tokens = st.slider(
            "Máx. tokens generados",
            min_value=64,
            max_value=512,
            value=256,
            step=32,
            help="Límite de tokens en la respuesta del modelo.",
        )

    st.markdown("---")
    st.markdown("### 🧪 Casos de prueba")
    st.caption("Haz clic para cargar el texto en el área de entrada.")

    test_cases = [
        "I like soccer",
        "How are you?",
        "What time is it?",
        "The weather is beautiful today.",
        "Machine learning is changing the world.",
    ]

    # Inicializar el estado de la sesión para el texto de entrada
    if "input_text" not in st.session_state:
        st.session_state["input_text"] = ""

    for case in test_cases:
        if st.button(f'"{case}"', use_container_width=True):
            st.session_state["input_text"] = case

    st.markdown("---")
    st.markdown(
        "<small>Modelo: **Qwen2-0.5B-Instruct**<br>"
        "Inferencia 100% local · Sin APIs externas</small>",
        unsafe_allow_html=True,
    )

# ---------------------------------------------------------------------------
# Contenido principal
# ---------------------------------------------------------------------------
st.markdown('<p class="main-title">🌐 Qwen2 Translator</p>', unsafe_allow_html=True)
st.markdown(
    '<p class="subtitle">Traducción de texto con IA local · Qwen2-0.5B-Instruct</p>',
    unsafe_allow_html=True,
)

# Área de texto de entrada
input_text = st.text_area(
    "Texto en inglés",
    value=st.session_state.get("input_text", ""),
    height=140,
    max_chars=2000,
    placeholder="Escribe o pega aquí el texto en inglés que deseas traducir…",
    help="Máximo 2 000 caracteres.",
)

col_btn, col_clear = st.columns([3, 1])
with col_btn:
    translate_btn = st.button(
        f"🔄 Traducir al {target_lang_label}",
        type="primary",
        use_container_width=True,
    )
with col_clear:
    if st.button("🗑️ Limpiar", use_container_width=True):
        st.session_state["input_text"] = ""
        st.rerun()

# ---------------------------------------------------------------------------
# Lógica de traducción
# ---------------------------------------------------------------------------
if translate_btn:
    if not input_text or not input_text.strip():
        st.warning("⚠️ Por favor, ingresa un texto antes de traducir.")
    else:
        # Cargar el modelo (con spinner visible al usuario)
        with st.spinner("⏳ Cargando modelo Qwen2-0.5B… (solo la primera vez)"):
            try:
                translator = load_translator()
                # Actualizar parámetros si el usuario los modificó
                translator.temperature = temperature
                translator.max_new_tokens = max_tokens
            except RuntimeError as e:
                st.error(f"❌ Error al cargar el modelo:\n\n{e}")
                st.stop()

        # Ejecutar la traducción
        with st.spinner(f"🔄 Traduciendo al {target_lang_label}…"):
            try:
                result = translator.translate(
                    text=input_text.strip(),
                    target_language=target_lang_code,
                )
            except ValueError as e:
                st.error(f"❌ Error de validación: {e}")
                st.stop()
            except Exception as e:
                st.error(
                    f"❌ Error inesperado durante la traducción:\n\n{e}\n\n"
                    "Intenta reducir el texto o reiniciar la aplicación."
                )
                st.stop()

        # Mostrar resultado
        st.markdown("---")
        st.markdown(f"#### Traducción al {target_lang_label}")
        st.markdown(
            f'<div class="translation-box">{result["translation"]}</div>',
            unsafe_allow_html=True,
        )

        # Métricas de rendimiento
        col1, col2, col3 = st.columns(3)
        col1.metric("⏱️ Tiempo", f'{result["elapsed_seconds"]} s')
        col2.metric("💻 Dispositivo", result["device"].upper())
        col3.metric("📝 Caracteres", len(result["translation"]))

        # Guardar en historial de la sesión
        if "history" not in st.session_state:
            st.session_state["history"] = []

        st.session_state["history"].insert(0, {
            "source": result["source_text"],
            "translation": result["translation"],
            "language": target_lang_label,
            "elapsed": result["elapsed_seconds"],
        })

        # Limitar historial a las últimas 10 entradas
        st.session_state["history"] = st.session_state["history"][:10]

# ---------------------------------------------------------------------------
# Historial de traducciones
# ---------------------------------------------------------------------------
if st.session_state.get("history"):
    st.markdown("---")
    st.markdown("#### 📋 Historial de traducciones")

    for i, entry in enumerate(st.session_state["history"]):
        with st.expander(
            f'[{entry["language"]}] "{entry["source"][:60]}…"'
            if len(entry["source"]) > 60
            else f'[{entry["language"]}] "{entry["source"]}"',
            expanded=(i == 0),
        ):
            col_src, col_tgt = st.columns(2)
            with col_src:
                st.markdown("**Original (EN)**")
                st.info(entry["source"])
            with col_tgt:
                st.markdown(f'**Traducción ({entry["language"]})**')
                st.success(entry["translation"])
            st.caption(f"⏱️ Tiempo de inferencia: {entry['elapsed']} s")

    if st.button("🗑️ Limpiar historial"):
        st.session_state["history"] = []
        st.rerun()
