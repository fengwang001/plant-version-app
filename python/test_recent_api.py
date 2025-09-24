#!/usr/bin/env python3
"""
测试最近识别API
"""

import requests
import json

def test_guest_login():
    """测试游客登录"""
    print("🔐 测试游客登录...")
    
    url = "http://localhost:8000/api/v1/auth/login/guest"
    data = {
        "device_id": "test_device_123",
        "device_type": "desktop"
    }
    
    try:
        response = requests.post(url, json=data)
        print(f"游客登录响应状态: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ 游客登录成功")
            print(f"响应内容: {result}")
            # 检查响应格式
            if 'access_token' in result:
                print(f"访问令牌: {result['access_token'][:20]}...")
                return result['access_token']
            else:
                print(f"❌ 响应格式异常: {result}")
                return None
        else:
            print(f"❌ 游客登录失败: {response.text}")
            return None
    except Exception as e:
        print(f"❌ 游客登录异常: {e}")
        return None

def test_recent_identifications(token):
    """测试获取最近识别"""
    print("\n📡 测试获取最近识别...")
    
    url = "http://localhost:8000/api/v1/plants/identifications?skip=0&limit=5"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.get(url, headers=headers)
        print(f"获取识别记录响应状态: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 获取识别记录成功，共 {len(data)} 条")
            for i, item in enumerate(data[:3]):
                print(f"  {i+1}. {item.get('common_name', 'Unknown')} - {item.get('created_at', 'N/A')}")
            return data
        else:
            print(f"❌ 获取识别记录失败: {response.text}")
            return None
    except Exception as e:
        print(f"❌ 获取识别记录异常: {e}")
        return None

def test_health_check():
    """测试健康检查"""
    print("🏥 测试健康检查...")
    
    url = "http://localhost:8000/api/v1/health"
    
    try:
        response = requests.get(url)
        print(f"健康检查响应状态: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 服务正常: {data}")
            return True
        else:
            print(f"❌ 服务异常: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 健康检查异常: {e}")
        return False

def main():
    print("🚀 开始API测试...\n")
    
    # 1. 健康检查
    if not test_health_check():
        print("❌ 后端服务不可用，请先启动后端服务")
        return
    
    # 2. 游客登录
    token = test_guest_login()
    if not token:
        print("❌ 无法获取访问令牌")
        return
    
    # 3. 获取最近识别
    identifications = test_recent_identifications(token)
    if identifications:
        print(f"\n🎉 API测试完成，成功获取 {len(identifications)} 条识别记录")
    else:
        print("\n❌ API测试失败，无法获取识别记录")

if __name__ == "__main__":
    main()
