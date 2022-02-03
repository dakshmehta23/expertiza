require './spec/support/teams_shared.rb'

describe TeamsUsersController do
  # Including the stubbed objects from the teams_shared.rb file
  include_context 'object initializations'
  #Objects initialization for team users
  let(:teamUser) { build(:team_user, id:1, team_id:1, user_id:1) }
  let(:teamUser2) { build(:team_user, id:2, team_id:1, user_id:2) }

  # Including the shared method from the teams_shared.rb file
  include_context 'authorization check'
  context 'not provides access to people with' do
    it 'student credentials' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be false
    end
  end

  #Test team users list functionality
  describe '#list' do
    context 'when list is clicked' do
    it 'renders list of users under Assignment team teams#users' do
      allow(Team).to receive(:find).with('1').and_return(team1)
      allow(Assignment).to receive(:find).with(1).and_return(assignment1)
      @params = {id:1}
      session = {user: instructor}
      get :list, @params, session
      expect(response).to render_template(:list)
    end
    end
  end

  #Test team users controller new method
  describe '#new' do
    it 'sets the Team object to instance variable' do
      allow(Team).to receive(:find).with('1').and_return(team1)
      params = {id:  1}
      session = {user: instructor}
      get :new, params, session
      expect(controller.instance_variable_get(:@team)).to eq(team1)
    end
  end

  #Test adding new user to assignment or course team
  describe '#create' do
    context 'when user is added to assignment or course team' do
    it 'it throws error when user is not defined' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(nil)
      allow(Team).to receive(:find).with('1').and_return(team1)
      session = {user: admin}
      params = {
          user: {name: 'instructor6'}, id: 1
      }
      post :create, params, session
      #Expect to throw error
      expect(flash[:error]).to eq "\"instructor6\" is not defined. Please <a href=\"http://test.host/users/new\">create</a> this user before continuing."
      #Expect the response to redirect to 'http://test.host/teams/list?id=1'
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when user is added to assignment team' do
    it 'it throws error when user added is not a participant of the current assignment' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(Team).to receive(:find).with('1').and_return(team1)
      allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
      allow(Assignment).to receive(:find).with(1).and_return(assignment1)
      allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)
      session = {user: admin}
      params = {
          user: {name: 'student2065'}, id: 1
      }
      post :create, params, session
      #Expect to throw error
      expect(flash[:error]).to eq "\"student2065\" is not a participant of the current assignment. Please <a href=\"http://test.host/participants/list?authorization=participant&id=1&model=Assignment\">add</a> this user before continuing."
      #Expect the response to redirect to 'http://test.host/teams/list?id=1'
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when user is added to assignment team' do
    it 'it throws error when assignmentTeam has maximum number of participants' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(Team).to receive(:find).with('1').and_return(team1)
      allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
      allow(Assignment).to receive(:find).with(1).and_return(assignment1)
      allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
      allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(false)
      session = {user: admin}
      params = {
          user: {name: 'student2065'}, id: 1
      }
      post :create, params, session
      #Expect to throw error
      expect(flash[:error]).to eq "This team already has the maximum number of members."
      #Expect the response to redirect to 'http://test.host/teams/list?id=1'
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when user is added to assignment team' do
      it 'new user gets successfully added to the assignment' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with(any_args).and_return(team1)
        allow(AssignmentTeam).to receive(:find).with('1').and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(true)
        allow(TeamsUser).to receive(:last).with(any_args).and_return(student1)
        session = {user: admin}
        params = {
            user: {name: 'student2065'}, id: 1
        }
        post :create, params, session
        #Expect the response to redirect to 'http://test.host/teams/list?id=1'
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end

    context 'when user is added to course team' do
    it 'it throws error when user added to course Team is not defined' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(Team).to receive(:find).with('5').and_return(team5)
      allow(CourseTeam).to receive(:find).with('5').and_return(team5)
      allow(Course).to receive(:find).with(1).and_return(course1)
      allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)
      session = {user: admin}
      params = {
          user: {name: 'student2065'}, id: 5
      }
      post :create, params, session
      #Expect to throw error
      expect(flash[:error]).to eq "\"student2065\" is not a participant of the current course. Please <a href=\"http://test.host/participants/list?authorization=participant&id=1&model=Course\">add</a> this user before continuing."
      #Expect the response to redirect to 'http://test.host/teams/list?id=1'
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when user is added to course team' do
    it 'it throws error when courseTeam has maximum number of participants' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(Team).to receive(:find).with('5').and_return(team5)
      allow(CourseTeam).to receive(:find).with('5').and_return(team5)
      allow(Course).to receive(:find).with(1).and_return(course1)
      allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
      allow_any_instance_of(CourseTeam).to receive(:add_member).with(any_args).and_return(false)
      session = {user: admin}
      params = {
          user: {name: 'student2065'}, id: 5
      }
      post :create, params, session
      #Expect to throw error
      expect(flash[:error]).to eq "This team already has the maximum number of members."
      #Expect the response to redirect to 'http://test.host/teams/list?id=1'
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end

    context 'when user is added to course team' do
      it 'new user gets successfully added to course' do
        allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
        allow(Team).to receive(:find).with('5').and_return(team5)
        allow(CourseTeam).to receive(:find).with('5').and_return(team5)
        allow(TeamsUser).to receive(:create).with(user_id: 1, team_id: 5).and_return(double('TeamsUser', id: 1))
        allow(TeamNode).to receive(:find_by).with(node_object_id: 5).and_return(double('TeamNode', id: 1))
        allow(TeamUserNode).to receive(:create).with(parent_id: 1, node_object_id: 1).and_return(double('TeamUserNode', id: 1))
        allow(Course).to receive(:find).with(1).and_return(course1)
        allow(CourseParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
        allow_any_instance_of(CourseTeam).to receive(:add_member).with(any_args).and_return(true)
        session = {user: admin}
        params = {
            user: {name: 'student2065'}, id: 5
        }
        post :create, params, session
        #Expect the response to redirect to 'http://test.host/teams/list?id=1'
        expect(response).to redirect_to('http://test.host/teams/list?id=1')
      end
    end
  end

  #Test delete user from team
  describe '#delete' do
    context 'when user is deleted' do
    it 'it deletes the user and redirects to Teams#list page' do
      allow(TeamsUser).to receive(:find).with("1").and_return(teamUser)
      allow(Team).to receive(:find).with(teamUser.team_id).and_return(team1)
      allow(User).to receive(:find).with(teamUser.user_id).and_return(student1)
      @params = {id:1}
      session = {user: instructor}
      post :delete, @params, session
      #Expect the response to redirect to 'http://test.host/teams/list?id=1'
      expect(response).to redirect_to('http://test.host/teams/list?id=1')
    end
    end
  end

  #Test delete selected users from team
  describe '#delete_selected' do
    context 'when selected users are deleted' do
      it 'it deletes the selected users and redirects to Teams#list page' do
        allow(TeamsUser).to receive(:find).with("1").and_return([teamUser])
        allow(TeamsUser).to receive(:find).with("2").and_return([teamUser2])
        @params = {item:[1,2]}
        session = {user: instructor}
        post :delete_selected, @params, session
        #Expect the response to redirect to 'http://test.host/teams_users/list'
        expect(response).to redirect_to('http://test.host/teams_users/list')
      end
    end
  end
end