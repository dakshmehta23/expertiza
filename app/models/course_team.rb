class CourseTeam < Team
  belongs_to : course, class_name: 'Course', foreign_key: 'parent_id'

  # Get the parent course. Useful for understanding the hierarchy and relationships.
  def parent_course
    Course.find(parent_id)
  end

  # A class method to find the parent course by its ID. Useful in class-level operations or queries.
  def self.find_parent_course(course_id)
    Course.find_by_id(course_id)
  end

  # Maintains a prototype instance of CourseTeam for use in patterns requiring a fresh instance.
  def self.prototype
    CourseTeam.new
  end

  # Facilitates copying this CourseTeam to an assignment team, adjusting for whether the assignment auto assigns mentors.
  def copy_to_assignment_team(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)
    new_team = if assignment&.auto_assign_mentor
                 MentoredTeam.create_team_and_node(assignment_id)
               else
                 AssignmentTeam.create_team_and_node(assignment_id)
               end
    new_team.name = name
    new_team.save
    members.each { |member| new_team.add_member(member) }
  end

  # Adds a user as a participant to the course team, ensuring they are not already part of it.
  def add_participant(user)
    CourseParticipant.find_or_create_by(parent: self.course, user: user) do |participant|
      participant.permission_granted = user.master_permission_granted
    end
  end

  # Delegates the import functionality to the TeamCsvHandler.
  def self.import_from_csv(row, course_id, options = {})
    TeamCsvHandler.import(row, course_id, options)
  end

  # Delegates the export functionality to the TeamCsvHandler.
  def self.export_to_csv(parent_id, options = {})
    TeamCsvHandler.export(parent_id, options)
  end

  # Defines the fields to be exported for the CSV, based on options provided.
  def self.export_fields(options = {})
    TeamCsvHandler.export_fields(options)
  end
end
