from django.db import models
from django.contrib.auth.models import User
from django.contrib.auth.models import AbstractUser

class Video(models.Model):
    app_label = 'video_app'
    
    CATEGORY_CHOICES = [
        ('다이어트', '다이어트'),
        ('근력 운동', '근력 운동'),
        ('스트레칭', '스트레칭'),
    ]
    video_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=200)
    category = models.CharField(max_length=10, choices=CATEGORY_CHOICES)
    url = models.CharField(max_length=300)
    duration = models.DurationField()
    
class User(AbstractUser):
    MBTI_CHOICES = (
        ('ESFP', 'ESFP'), ('ESFJ', 'ESFJ'), ('ESTP', 'ESTP'), ('ESTJ', 'ESTJ'),
        ('ENFP', 'ENFP'), ('ENFJ', 'ENFJ'), ('ENTP', 'ENTP'), ('ENTJ', 'ENTJ'),
        ('ISFP', 'ISFP'), ('ISFJ', 'ISFJ'), ('ISTP', 'ISTP'), ('ISTJ', 'ISTJ'),
        ('INFP', 'INFP'), ('INFJ', 'INFJ'), ('INTP', 'INTP'), ('INTJ', 'INTJ'),
        
    )
    mbti = models.CharField(max_length=4, choices=MBTI_CHOICES, null=True, blank=True)
    groups = models.ManyToManyField('auth.Group', related_name='video_app_groups')
    user_permissions = models.ManyToManyField('auth.Permission', related_name='video_app_permissions')

class ViewStatus(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    id = models.AutoField(primary_key=True)
    mbti = models.CharField(max_length=4, choices=User.MBTI_CHOICES)
    video = models.ForeignKey(Video, on_delete=models.CASCADE)
    cluster_watch_score = models.FloatField()

    class Meta:
        unique_together = ('mbti', 'video')

    @classmethod
    def calculate_cluster_watch_score(cls, video_id):
        from user_app.models import User, ViewScore
        with transaction.atomic():
            cluster_watch_scores = (
                ViewScore.objects.filter(video_id=video_id)
                .values('user__user_mbti')
                .annotate(cluster_watch_score=Sum('watch_score'))
            )
            for score in cluster_watch_scores:
                mbti = score['user__user_mbti']
                watch_score = score['cluster_watch_score']
                cls.objects.update_or_create(
                    mbti=mbti, video_id=video_id, defaults={'cluster_watch_score': watch_score}
                )