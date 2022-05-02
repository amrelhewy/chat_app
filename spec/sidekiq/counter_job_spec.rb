# frozen_string_literal: true

require 'rails_helper'
RSpec.describe CounterJob, type: :job do
  it { is_expected.to be_processed_in :default }
end
