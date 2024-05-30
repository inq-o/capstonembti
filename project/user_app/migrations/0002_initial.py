# Generated by Django 5.0.6 on 2024-05-30 01:35

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True

    dependencies = [
        ("user_app", "0001_initial"),
        ("video_app", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="videowatch",
            name="video",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE, to="video_app.video"
            ),
        ),
        migrations.AddField(
            model_name="viewhistory",
            name="user",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE, to="user_app.user"
            ),
        ),
        migrations.AddField(
            model_name="viewhistory",
            name="video",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE, to="video_app.video"
            ),
        ),
        migrations.AddField(
            model_name="viewscore",
            name="user",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE, to="user_app.user"
            ),
        ),
        migrations.AddField(
            model_name="viewscore",
            name="video",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE, to="video_app.video"
            ),
        ),
        migrations.AlterUniqueTogether(
            name="viewscore",
            unique_together={("user", "video")},
        ),
    ]