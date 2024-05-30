from django.db import models, transaction
from django.db.models.signals import post_save
from django.dispatch import receiver
from video_app.models import Video
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    MBTI_CHOICES = [
        ('ESFP', 'ESFP'), ('ESFJ', 'ESFJ'), ('ESTP', 'ESTP'), ('ESTJ', 'ESTJ'),
        ('ENFP', 'ENFP'), ('ENFJ', 'ENFJ'), ('ENTP', 'ENTP'), ('ENTJ', 'ENTJ'),
        ('ISFP', 'ISFP'), ('ISFJ', 'ISFJ'), ('ISTP', 'ISTP'), ('ISTJ', 'ISTJ'),
        ('INFP', 'INFP'), ('INFJ', 'INFJ'), ('INTP', 'INTP'), ('INTJ', 'INTJ'),
    ]
    SEX_CHOICES = [
        ('남성', '남성'),
        ('여성', '여성'),
    ]
    user_id = models.AutoField(primary_key=True)
    user_mbti = models.CharField(max_length=4, choices=MBTI_CHOICES)
    name = models.CharField(max_length=20)
    birth_date = models.DateField()
    sex = models.CharField(max_length=2, choices=SEX_CHOICES)
    phone_number = models.CharField(max_length=20)
    height = models.FloatField(null=True, blank=True)
    weight = models.FloatField(null=True, blank=True)
    groups = models.ManyToManyField('auth.Group', related_name='user_app_groups')
    user_permissions = models.ManyToManyField('auth.Permission', related_name='user_app_permissions')
    
    pass

class ViewHistory(models.Model):
    view_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    video = models.ForeignKey(Video, on_delete=models.CASCADE)
    view_date = models.DateField()
    start_time = models.DateTimeField()
    end_time = models.DateTimeField(auto_now_add=True)
    duration_seconds = models.IntegerField()

class ViewScore(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    video = models.ForeignKey(Video, on_delete=models.CASCADE)
    watch_score = models.FloatField()

    class Meta:
        unique_together = ('user', 'video')

    @classmethod
    def calculate_user_watch_score(cls, user_id, video_id):
        with transaction.atomic():
            view_history = ViewHistory.objects.filter(user_id=user_id, video_id=video_id).first()
            if view_history:
                video = Video.objects.get(id=video_id)
                watch_score = view_history.duration_seconds / video.duration.total_seconds()
                cls.objects.create(user_id=user_id, video_id=video_id, watch_score=watch_score)

class VideoWatch(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    video = models.ForeignKey(Video, on_delete=models.CASCADE)
    duration_seconds = models.IntegerField(help_text="Watch duration in seconds")
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.user.name} watched {self.video.title} for {self.duration_seconds} seconds"

@receiver(post_save, sender=ViewHistory)
def trigger_calculate_watch_scores(sender, instance, created, **kwargs):
    if created:
        ViewScore.calculate_user_watch_score(instance.user_id, instance.video_id)
        ViewStatus.calculate_cluster_watch_score(instance.video_id)