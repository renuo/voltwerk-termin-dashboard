# frozen_string_literal: true

class SyncJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # rubocop: disable Rails/Output
    puts "this does something"
    # rubocop: enable Rails/Output
  end
end
