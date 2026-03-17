import os
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader, Settings, PromptTemplate
from llama_index.llms.groq import Groq
from llama_index.embeddings.fastembed import FastEmbedEmbedding
from dotenv import load_dotenv

load_dotenv()

# --- CUSTOM PROMPTS FOR "BEST MENTAL HEALTH BOT" ---

# 1. Text QA Prompt (The Core Answer Generator)
# Injects the "MAA" persona into the RAG response.
QA_PROMPT_TMPL = (
    "You are MAA, an empathetic and professional mental health guide. "
    "Your goal is to provide comforting, evidence-based support using the context below.\n\n"
    "context_str:\n"
    "---------------------\n"
    "{context_str}\n"
    "---------------------\n"
    "INSTRUCTIONS:\n"
    "1. Use the context above to answer the user's question.\n"
    "2. Be warm, non-judgmental, and concise (2-3 sentences max usually).\n"
    "3. If the context doesn't have the answer, kindly say you don't know but offer general support.\n"
    "4. Do NOT say 'According to the document' or 'The context says'. Just give the advice naturally.\n"
    "5. Use active listening: 'It sounds like...'\n\n"
    "Query: {query_str}\n"
    "MAA's Response:"
)
QA_PROMPT = PromptTemplate(QA_PROMPT_TMPL)

# 2. Refine Prompt (For when answer needs to be improved iteratively)
REFINE_PROMPT_TMPL = (
    "The original query is: {query_str}\n"
    "We have provided an existing answer: {existing_answer}\n"
    "We have the opportunity to refine the existing answer "
    "(only if needed) with some more context below.\n"
    "------------\n"
    "{context_msg}\n"
    "------------\n"
    "Given the new context, refine the original answer to be more helpful and empathetic. "
    "If the context isn't useful, return the original answer.\n"
    "MAA's Refined Response:"
)
REFINE_PROMPT = PromptTemplate(REFINE_PROMPT_TMPL)

# Global variables to hold singletons
query_engine = None
is_initialized = False

def _initialize_engine():
    global query_engine, is_initialized
    if is_initialized:
        return
        
    try:
        # 1. Setup LLM (Groq - Llama 3)
        groq_api_key = os.getenv("GROQ_API_KEY")
        if not groq_api_key:
            print("GROQ_API_KEY not found in .env")
            is_initialized = True
            return
            
        llm = Groq(model="llama-3.1-8b-instant", api_key=groq_api_key)
        
        # 2. Setup Embeddings (FastEmbed - ~100x lighter than local torch huggingface, fits in 512MB RAM)
        embed_model = FastEmbedEmbedding(model_name="BAAI/bge-small-en-v1.5")
        
        # 3. Configure Global Settings
        Settings.llm = llm
        Settings.embed_model = embed_model
        
        # 4. Load Data & Create Index
        data_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")
        if os.path.exists(data_dir) or os.path.exists("data"):
            path_to_use = data_dir if os.path.exists(data_dir) else "data"
            print(f"📂 Loading documents from {path_to_use}...")
            documents = SimpleDirectoryReader(path_to_use).load_data()
            print(f"✅ Loaded {len(documents)} documents. Creating AI Index...")
            index = VectorStoreIndex.from_documents(documents)
            print("✅ AI Index created successfully!")
            
            # 5. Create Query Engine
            query_engine = index.as_query_engine(
                text_qa_template=QA_PROMPT,
                refine_template=REFINE_PROMPT,
                streaming=False
            )
        else:
            print("Data directory not found.")
            
    except Exception as e:
        print(f"Error setting up Doc Engine: {e}")
        
    finally:
        is_initialized = True

def query_documents(user_query: str) -> str:
    _initialize_engine()
    
    if not query_engine:
        return "Error: Document engine not ready. Check logs/data folder."
    
    try:
        response = query_engine.query(user_query)
        return str(response)
    except Exception as e:
        return f"I'm having trouble reading my guides right now. ({str(e)})"
