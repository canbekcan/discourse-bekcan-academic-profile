# frozen_string_literal: true

module ::DiscourseBekcanAcademicProfile
  class AcademicProfileSerializer < ::ApplicationSerializer
    attributes :titles, :mappings, :groups

    def titles
      object[:titles]
    end

    def mappings
      object[:mappings]
    end

    def groups
      object[:groups]
    end
  end
end