from django.db import models
from django.contrib.auth.models import User

class VideoWatch(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    video_id = models.CharField(max_length=100)
    watch_time = models.IntegerField(help_text="Watch time in seconds")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} watched {self.video_id} for {self.watch_time} seconds"
