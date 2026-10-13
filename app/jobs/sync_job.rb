# frozen_string_literal: true

class SyncJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Rails.logger.debug "this does something"
  end
end
