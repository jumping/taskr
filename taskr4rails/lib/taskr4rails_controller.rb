class Taskr4railsController < ActionController::Base
  
  def execute
    unless Object.const_defined?("TASKR4RAILS_AUTH")
      render :text => "The taskr4rails receiver cannot be used until TASKR4RAILS_AUTH is defined. See http://code.google.com/p/ruby-taskr/wiki/Taskr4rails for help.", 
        :status => 500
      return false
    end
    
    unless request.post?
      render :text => "This is the taskr4rails receiver. It responds only to POST requests.", 
        :status => 405
      return false
    end
    
    if Object.const_defined?("TASKR4RAILS_ALLOWED_HOSTS")
      ok = TASKR4RAILS_ALLOWED_HOSTS.any? do |h|
        if h.kind_of? Regexp
          h =~ request.remote_addr
        else
          h == request.remote_addr
        end
      end
      
      unless ok
        render :text => "Remote address is not in the list of permitted hosts.",
        :status => 403
        return false
      end
    end
    
    unless params[:auth] == TASKR4RAILS_AUTH
      render :text => "Invalid auth password.",
        :status => 401
      return false
    end
    
    io = StringIO.new
    prev_stdout, prev_stderr = $stdout, $stderr
    output = ""
    $stdout = io
    $stderr = io
    begin
      eval(params[:ruby_code]) if params[:ruby_code]
      #output << (`cd #{RAILS_ROOT}; #{params[:shell_command]}` || "") if params[:shell_command]
      err = false
    rescue => e
      output << "#{e.class}: #{e}\n\nBACKTRACE:\n#{e.backtrace.join("\n")}"
      err = true
    end
    $stdout = prev_stdout
    $stderr = prev_stderr
    output = io.read(nil)
    
    render :text => output, :status => (err ? 500 : 200)
  end
  
end