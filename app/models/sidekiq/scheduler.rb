class Sidekiq::Scheduler
  def self.schedule_uniq_job(job_class, *, at:)
    new(job_class, *, at: at).schedule_uniq_job
  end

  def initialize(job_class, *args, at:, queue: "default")
    @job_class = job_class
    @args = args
    @at = at
    @queue = queue
  end

  def schedule_uniq_job
    if existing_job
      reschedule_existing_job
    else
      @job_class.set(wait_until: @at, queue: @queue).perform_later(*@args)
    end
  end

  private

  def scheduled_set
    @scheduled_set ||= Sidekiq::ScheduledSet.new
  end

  def existing_job
    @existing_job ||= scheduled_set.find do |job|
      job.queue == @queue && job.display_class == @job_class.to_s &&
        job.display_args == @args
    end
  end

  def reschedule_existing_job
    existing_job.reschedule(@at)
  end
end
