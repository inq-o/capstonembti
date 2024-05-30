from django.urls import path
from . import views

app_name = 'video_app'
urlpatterns = [
    path('video/<int:video_id>/', views.show_video, name='show_video'),
    path('video_watch/<int:video_watch_id>/end/', views.end_video_watch, name='end_video_watch'),
]

urlpatterns += [
    path('video/watch/start/', views.start_video_watch, name='start_video_watch'),
]