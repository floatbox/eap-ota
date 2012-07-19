# пусть валяются в таблице
Delayed::Worker.destroy_failed_jobs = false
# как часто дергать базу, если новых задач нет
Delayed::Worker.sleep_delay = 60
# дефолтное количество повторов сфейлившихся задач
# можно оверрайдить в конкретной задаче
Delayed::Worker.max_attempts = 3
# максимальное время работы одной задачи, прежде чем случится таймаут
Delayed::Worker.max_run_time = 5.minutes
#количество задач, которые блокирует на себя один воркер за раз
#Delayed::Worker.read_ahead = 10
# делать задачи неасинхронно в тестах.
#Delayed::Worker.delay_jobs = !Rails.env.test?
