from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

class PlantDetailsError(Exception):
    """植物详细信息获取错误基类"""
    pass

class OpenAIAPIError(PlantDetailsError):
    """OpenAI API 错误"""
    pass

class InvalidPlantDataError(PlantDetailsError):
    """无效的植物数据"""
    pass

def setup_exception_handlers(app: FastAPI):
    """设置全局异常处理器"""
    
    @app.exception_handler(OpenAIAPIError)
    async def openai_error_handler(request: Request, exc: OpenAIAPIError):
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "error": "openai_api_error",
                "message": str(exc),
                "detail": "AI 服务暂时不可用"
            }
        )
    
    @app.exception_handler(InvalidPlantDataError)
    async def invalid_data_handler(request: Request, exc: InvalidPlantDataError):
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={
                "error": "invalid_plant_data",
                "message": str(exc),
                "detail": "植物数据格式不正确"
            }
        )