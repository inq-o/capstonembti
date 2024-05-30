from django.http import JsonResponse
from django.contrib.auth.models import User
from django.views.decorators.csrf import csrf_exempt
import json

@csrf_exempt
def create_test_user(request):
    if request.method == 'POST':
        try:
            # 테스트용 사용자 생성
            user = User.objects.create_user(username='testuser', password='password123', email='test@example.com')
            
            # 생성한 사용자의 ID 반환
            user_id = user.id
            
            # 생성한 사용자의 ID를 JSON 응답으로 반환
            return JsonResponse({"user_id": user_id})
        except Exception as e:
            # 오류가 발생한 경우 오류 메시지를 반환
            return JsonResponse({"error": str(e)}, status=500)
    else:
        # POST 요청이 아닌 경우 405 Method Not Allowed 오류 반환
        return JsonResponse({"error": "Method Not Allowed"}, status=405)