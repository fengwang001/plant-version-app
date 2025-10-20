"""应用程序配置"""
from typing import Optional
from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """应用程序设置"""
    
    # 应用配置
    app_name: str = Field(default="PlantVision API", alias="APP_NAME")
    app_version: str = Field(default="1.0.0", alias="APP_VERSION")
    debug: bool = Field(default=False, alias="DEBUG")
    secret_key: str = Field(..., alias="SECRET_KEY")
    
    # 数据库配置
    database_url: str = Field(..., alias="DATABASE_URL")
    database_url_sync: str = Field(..., alias="DATABASE_URL_SYNC")
    
    # Redis 配置
    redis_url: str = Field(default="redis://localhost:6379/0", alias="REDIS_URL")
    
    # Celery 配置
    celery_broker_url: str = Field(default="redis://localhost:6379/1", alias="CELERY_BROKER_URL")
    celery_result_backend: str = Field(default="redis://localhost:6379/2", alias="CELERY_RESULT_BACKEND")
    
    # JWT 配置
    jwt_secret_key: str = Field(..., alias="JWT_SECRET_KEY")
    jwt_algorithm: str = Field(default="HS256", alias="JWT_ALGORITHM")
    access_token_expire_minutes: int = Field(default=30, alias="ACCESS_TOKEN_EXPIRE_MINUTES")
    refresh_token_expire_days: int = Field(default=7, alias="REFRESH_TOKEN_EXPIRE_DAYS")
    
    # AWS S3 配置
    aws_access_key_id: Optional[str] = Field(default=None, alias="AWS_ACCESS_KEY_ID")
    aws_secret_access_key: Optional[str] = Field(default=None, alias="AWS_SECRET_ACCESS_KEY")
    aws_bucket_name: Optional[str] = Field(default=None, alias="AWS_BUCKET_NAME")
    aws_region: str = Field(default="us-east-1", alias="AWS_REGION")
    aws_endpoint_url: Optional[str] = Field(default=None, alias="AWS_ENDPOINT_URL")

      # OpenAI API 配置（新增）
    OPENAI_API_KEY: str = "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"
    OPENAI_API_URL: str = "https://api.openai.com/v1"
    OPENAI_MODEL: str = "gpt-4-turbo-preview"
    
    # Plant.id API 配置
    plant_id_api_key: Optional[str] = Field(default="vMULjQwS7sm5KpAffcP6ELsTn3D2jLjqNyNzHDnw734sVf2tMG", alias="PLANT_ID_API_KEY")
    plant_id_api_url: str = Field(default="https://plant.id/api/v3", alias="PLANT_ID_API_URL")
    
    # Replicate API 配置
    replicate_api_token: Optional[str] = Field(default=None, alias="REPLICATE_API_TOKEN")
    
    # Apple 登录配置
    apple_team_id: Optional[str] = Field(default=None, alias="APPLE_TEAM_ID")
    apple_key_id: Optional[str] = Field(default=None, alias="APPLE_KEY_ID")
    apple_private_key_path: Optional[str] = Field(default=None, alias="APPLE_PRIVATE_KEY_PATH")
    
    # Google 登录配置
    google_client_id: Optional[str] = Field(default=None, alias="GOOGLE_CLIENT_ID")
    google_client_secret: Optional[str] = Field(default=None, alias="GOOGLE_CLIENT_SECRET")
    
    # RevenueCat 配置
    revenuecat_api_key: Optional[str] = Field(default=None, alias="REVENUECAT_API_KEY")
    revenuecat_webhook_secret: Optional[str] = Field(default=None, alias="REVENUECAT_WEBHOOK_SECRET")
    
    # Stripe 配置
    stripe_publishable_key: Optional[str] = Field(default=None, alias="STRIPE_PUBLISHABLE_KEY")
    stripe_secret_key: Optional[str] = Field(default=None, alias="STRIPE_SECRET_KEY")
    stripe_webhook_secret: Optional[str] = Field(default=None, alias="STRIPE_WEBHOOK_SECRET")
    
    # 邮件配置
    smtp_host: Optional[str] = Field(default=None, alias="SMTP_HOST")
    smtp_port: int = Field(default=587, alias="SMTP_PORT")
    smtp_user: Optional[str] = Field(default=None, alias="SMTP_USER")
    smtp_password: Optional[str] = Field(default=None, alias="SMTP_PASSWORD")
    
    # 监控配置
    sentry_dsn: Optional[str] = Field(default=None, alias="SENTRY_DSN")

    # 调试模式
    DEBUG: bool = False
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


# 全局设置实例
settings = Settings()
