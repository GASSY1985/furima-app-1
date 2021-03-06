class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only:[:index, :show, :like, :search]
  before_action :set_category_parent_array, only: [:new, :create, :edit, :update]
  before_action :delete_photos,only: [:update] 
  before_action :authenticate_user!, only: [:new,:create,:edit,:update]

  # 商品一覧表示(トップページ)用のアクション
  def index
    @items = Item.where(buyer_id: nil).order("created_at DESC").limit(6)
  end

  # 商品出品用のアクション
  def new
    @item = Item.new
  end

  # 商品出品時のデータ保存用アクション
  def create
    @item = Item.new(create_params)
    if @item.save
      redirect_to controller: :users, action: :show, id: current_user.id
    else
      render action: :new, notice: "fail"
    end        
  end

  # 商品出品時のカテゴリー取得に使用
  def get_category_children
    @category_children = Category.where('ancestry = ?', "#{params[:parent_name]}")
  end

  def get_category_grandchildren
    @category_grandchildren = Category.where('ancestry LIKE ?', "%/#{params[:child_id]}")
  end
  
  # 商品詳細表示用のアクション
  def show
    if @item.category.parent == nil
      # 一番上のカテゴリ
      @parent = @item.category.name
    elsif @item.category.parent.parent == nil
      # 真ん中のカテゴリ
      @parent = @item.category.parent.name
      @child = @item.category.name
    else
      # 一番下のカテゴリ
      @parent = @item.category.parent.parent.name
      @child = @item.category.parent.name
      @grand_child = @item.category.name
    end
    @like = Like.new
  end
  
  # 商品情報編集用のアクション
  def edit
    @grandchild = @item.category
    @child = @grandchild.parent
    @parent = @grandchild.parent.parent
    @category = @item.category
    @category_children_array = Category.where('ancestry = ?', "#{@category.parent.ancestry}")
    @category_grandchildren_array = Category.where('ancestry = ?', "#{@category.ancestry}")
  end

  # 商品情報編集時のデータ保存用アクション
  def update
    if @item.update(create_params)
      redirect_to item_path(@item), notice: "商品名「#{@item.name}」の情報を更新しました。"
    else
      redirect_to edit_item_path, notice: "商品名「#{@item.name}」の情報を不足いています。"
    end
  end

  # 商品削除用のアクション
  def destroy
    @item.destroy
    redirect_to user_path(current_user), notice: "商品名「#{@item.name}」を削除しました。"
  end

  def like
    @items = Item.joins(:likes).order(created_at: :desc).page(params[:page]).per(10)
  end

  # ヘッダー商品検索用のアクション
  def search
    @items = Item.where('name LIKE(?)', "%#{params[:search]}%").page(params[:page]).per(30)
  end

private

  # 商品出品時のparams
  def create_params
    params.require(:item).permit(:name, :text, :category_id, :brand_name, :status, :shipping_charges, :shipping_area, :days_to_ship, :price, photos:[]).merge(saler_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def set_categories
    @categories = Category.all
  end

  def set_category_parent_array
    @category_parent_array = Category.where(ancestry: nil)
  end

  def delete_photos
    delete_photos = params[:item][:delete_photo_ids]
    if delete_photos != nil
      delete_photos.each do |photo_ids|
        delete_photo = @item.photos.find(photo_ids)
        delete_photo.purge
      end
    end
  end

end



