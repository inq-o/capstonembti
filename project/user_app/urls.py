from django.urls import path
from . import views

app_name = 'user_app'

urlpatterns = [
    path('<int:user_id>/', views.user_profile, name='user_profile'),
    path('video/<int:video_id>/start/', views.start_video_watch, name='start_video_watch'),
    path('video_watch/<int:video_watch_id>/end/', views.end_video_watch, name='end_video_watch'),
]