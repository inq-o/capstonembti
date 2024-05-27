from django.contrib import admin
from django.urls import path
from htapp.views import show_video

urlpatterns = [
    path('show_video/<str:video_id>/', show_video, name='show_video'),  
    path('admin/', admin.site.urls),
]
