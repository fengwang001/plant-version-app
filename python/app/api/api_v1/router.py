"""API v1 主路由"""
from fastapi import APIRouter
from .endpoints import auth, plants, media, users, subscriptions, posts

api_router = APIRouter()

# 注册各个模块的路由
api_router.include_router(auth.router, prefix="/auth", tags=["认证"])
api_router.include_router(users.router, prefix="/users", tags=["用户"])
api_router.include_router(plants.router, prefix="/plants", tags=["植物"])
api_router.include_router(media.router, prefix="/media", tags=["媒体"])
api_router.include_router(subscriptions.router, prefix="/subscriptions", tags=["订阅"])
api_router.include_router(posts.router, prefix="/posts", tags=["作品"])





