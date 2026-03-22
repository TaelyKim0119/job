from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "직감 API"
    app_env: str = "development"
    app_debug: bool = True

    # OpenAI
    openai_api_key: str = ""

    # Supabase
    supabase_url: str = ""
    supabase_key: str = ""
    supabase_service_key: str = ""

    # Google Gemini
    gemini_api_key: str = ""

    # Replicate
    replicate_api_token: str = ""

    class Config:
        env_file = ".env"


settings = Settings()
