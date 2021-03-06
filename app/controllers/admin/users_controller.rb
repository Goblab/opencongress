class Admin::UsersController < Admin::IndexController
  before_filter :admin_login_required

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @query = params[:q]
    unless params[:q].blank?
      @users = User.where(["users.login ILIKE ?", "%#{params[:q]}%"]).order('users.login ASC').paginate(:page => params[:page])
    else
      @users = User.order('users.login ASC').paginate(:page => params[:page])
    end
	end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def make_watch_dog
     @user = User.find_by_id(params[:id])
     if @user.definitive_district
       WatchDog.destroy_all("district_id = #{@user.definitive_district}")
       wd =  WatchDog.find_or_initialize_by_district_id_and_user_id(@user.definitive_district, @user.id)
       wd.is_active = true
       wd.save
     end
     redirect_to :action => 'edit', :id => @user
  end

  def resend_confirmation
     @user = User.find_by_id(params[:id])
     UserNotifier.signup_notification(@user).deliver
     redirect_to :action => 'edit', :id => @user
  end

  def activate_user
    @user = User.find_by_id(params[:id])
    @user.activate!
    redirect_to :action => 'edit', :id => @user
  end

  def destroy
    User.find(params[:id]).deactivate!
    flash[:notice] = 'User deactivated!'

    redirect_to :action => 'list'
  end
end
