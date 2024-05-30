from django.shortcuts import render, get_object_or_404
from django.contrib.auth.decorators import login_required
from .models import Video, ViewStatus
from django.http import JsonResponse
from user_app.models import VideoWatch
from django.views.decorators.csrf import csrf_exempt
import json

@login_required
def video_detail(request, video_id):
    video = get_object_or_404(Video, id=video_id)
    view_statuses = ViewStatus.objects.filter(video=video)
    context = {
        'video': video,
        'view_statuses': view_statuses,
    }
    return render(request, 'video_app/video_detail.html', context)

@csrf_exempt
def show_video(request, video_id):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            user_id = data.get('user_id')
            watch_time = data.get('watch_time_seconds')
            user = request.user
            VideoWatch.objects.create(user=user, video_id=video_id, watch_time=watch_time)
            return JsonResponse({"message": "Watch time saved successfully"})
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON"}, status=400)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)
    else:
        view_statuses = ViewStatus.objects.filter(video_id=video_id)
        context = {
            'view_statuses': view_statuses,
        }
        return render(request, 'video_app/show_video.html', context)

@login_required
def start_video_watch(request):
    context = {
        'duration_seconds': request.GET.get('duration_seconds', 0),
    }
    if context['duration_seconds']:
        context['duration_seconds'] = int(context['duration_seconds'])
    return render(request, 'video_app/start_video_watch.html', context)

@login_required
def end_video_watch(request):
    return render(request, 'video_app/end_video_watch.html')