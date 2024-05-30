from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.utils import timezone
from .models import User, ViewHistory, ViewScore, VideoWatch
from video_app.models import Video

@login_required
def user_profile(request, user_id):
    user = get_object_or_404(User, id=user_id)
    view_history = ViewHistory.objects.filter(user=user).order_by('-view_date')
    view_scores = ViewScore.objects.filter(user=user)
    video_watches = VideoWatch.objects.filter(user=user)
    context = {
        'user': user,
        'view_history': view_history,
        'view_scores': view_scores,
        'video_watches': video_watches,
    }
    return render(request, 'user_app/user_profile.html', context)

@login_required
def start_video_watch(request, video_id):
    video = get_object_or_404(Video, id=video_id)
    video_watch = VideoWatch.objects.create(
        user=request.user,
        video=video,
        start_time=timezone.now()
    )
    return redirect('video_app:video_detail', video_id=video.id)

@login_required
def end_video_watch(request, video_watch_id):
    video_watch = get_object_or_404(VideoWatch, id=video_watch_id, user=request.user)
    video_watch.end_time = timezone.now()
    video_watch.duration_seconds = (video_watch.end_time - video_watch.start_time).total_seconds()
    video_watch.save()
    return redirect('user_app:user_profile', user_id=request.user.id)