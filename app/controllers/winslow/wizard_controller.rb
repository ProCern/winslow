class Winslow::WizardController < ApplicationController
  helper_method :wizard_path

  before_filter :setup_wizard

  class << self
    def add_step(step)
      @wizard_steps ||= []
      @wizard_steps << step
      @wizard_steps
    end

    def steps
      @wizard_steps
    end

    def return_step_query_params(query_params = nil)
      @return_step_query_params = query_params if query_params
      @return_step_query_params
    end
  end

  def step
    @step
  end

  def next_wizard_path
    wizard_path @next_step
  end

  def steps
    self.class.steps
  end

  def return_step_query_params
    self.class.return_step_query_params
  end

  def finish_wizard_path
    '/'
  end

  def wizard_path(step = nil, options = {})
    step ||= params[:id]
    options = step.merge(options) if step.is_a?(Hash)
    options = options.with_indifferent_access

    if step == last_step
      last_wizard_path
    elsif step.is_a?(Hash)
      if Winslow.configuration.resource_lookup
        path = Winslow.configuration.resource_lookup.call(options)
        raise "Unable to find resource path - #{options.inspect}" unless path

        query_string = build_query_string(step, options)

        if query_string.length > 0
          path << (path.include?('?') ? '&' : '?')
          path << query_string
        end

        path = path.gsub(/^https?:\/\//, request.protocol)
        path
      else
        raise 'No resource lookup method defined'
      end
    else
      options = { :id => step, :controller => params[:controller], :action => 'show', :only_path => true }.merge(options)
      url_for(options)
    end
  end

  def render_wizard(resource = nil)
    @skip_to = @next_step if resource && resource.save

    if @skip_to.present?
      redirect_to wizard_path(@skip_to)
    else
      render_step @step
    end
  end

  private

  def setup_wizard
    @step = params[:id].try(:to_sym) || steps.first
    @next_step = next_step(@step)

    if params[:return_to]
      session[:wizard_return_to] = params[:return_to]
    end
  end

  def next_step(current_step)
    index = steps.index(current_step)
    step = steps.at(index + 1) if index.present?
    step ||= last_step
    step
  end

  def last_step
    return_to? ? :return : :finish
  end

  def last_wizard_path
    if return_to?
      return_location
    else
      finish_wizard_path
    end
  end

  def return_to?
    session[:wizard_return_to].present?
  end

  def return_location
    url = session[:wizard_return_to]
    session.delete 'wizard_return_to'

    if return_step_query_params
      query_string = extract_query_params(return_step_query_params).join('&')
      url << if url.include? '?'
               '&'
             else
               '?'
             end
      url << query_string
    end

    url
  end

  def render_step(step)
    if step.nil? || step == last_step
      redirect_to last_wizard_path
    else
      render step
    end
  end

  def extract_query_params(query_params)
    if query_params && query_params.respond_to?(:call)
      query_params = query_params.call(self)
    end

    if query_params
      new_query_params = []
      query_params.each { |key, value| new_query_params << "#{key}=#{value}" }
      query_params = new_query_params
    end

    query_params || []
  end

  def build_query_string(step, options)
    query_params = extract_query_params(options[:query_params])
    next_step = next_step(step)

    if next_step
      query_params ||= []
      query_params << "return_to=#{wizard_path(next_step, :only_path => false)}"
    end

    query_params.join('&')
  end
end
