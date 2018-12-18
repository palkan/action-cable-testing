# frozen_string_literal: true

class User
    include GlobalID::Identification

    attr_reader :id

    def initialize(id)
      @id = id
    end
  end
