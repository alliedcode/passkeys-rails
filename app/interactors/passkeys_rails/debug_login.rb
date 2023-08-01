# This functionality exists to allow easier mobile app debugging as it may not
# be possible to acess Passkey functionality in mobile simulators.
# It is only operational if DEBUG_LOGIN_REGEX is set in the server environment.
# CAUTION: It is very insecure to set DEBUG_LOGIN_REGEX in a production environment.
module PasskeysRails
  class DebugLogin
    include Interactor
    include Debuggable

    delegate :username, to: :context

    def call
      ensure_debug_mode
      ensure_regex_match

      context.agent = agent
      context.username = agent.username
      context.auth_token = GenerateAuthToken.call!(agent:).auth_token
    rescue Interactor::Failure => e
      context.fail! code: e.context.code, message: e.context.message
    end

    private

    def agent
      @agent ||= begin
        agent = Agent.find_by(username:)
        context.fail!(code: :agent_not_found, message: "No agent found with that username") if agent.blank?
        agent
      end
    end
  end
end
