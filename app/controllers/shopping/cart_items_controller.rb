class Shopping::CartItemsController < Shopping::BaseController

  # GET /shopping/cart_items
  def index
    @cart_items       = session_cart.shopping_cart_items
    @saved_cart_items = session_cart.saved_cart_items
  end

  # POST /shopping/cart_items
  def create
    session_cart.save if session_cart.new_record?
    if params[:cart_item]
      qty = params[:cart_item][:quantity].to_i
      vari = params[:cart_item][:variant_id]
    else
      qty = params[:quantity].to_i
      vari = params[:variant_id]
    end
    
    if cart_item = session_cart.add_variant(vari, most_likely_user, qty)
      session_cart.save_user(most_likely_user)
      #flash[:success] = "Item added succesfully in cart"
        respond_to do |format|
          format.js
        end
    else
      variant = Variant.includes(:food).find_by_id(params[:cart_item][:variant_id])
      if variant
        redirect_to(product_url(variant.product))
      else
        flash[:notice] = "Something went wrong"
        redirect_to root_path
      end
    end
  end

  # PUT /carts/1
  def update
    if session_cart.update_attributes(allowed_params)
      if params[:commit] && params[:commit] == "Checkout"
        redirect_to( checkout_shopping_order_url('Checkout'))
      else
        redirect_to(shopping_cart_items_url(), :notice => I18n.t('item_passed_update') )
      end
    else
      redirect_to(shopping_cart_items_url(), :notice => I18n.t('item_failed_update') )
    end
  end
## TODO
  ## This method moves saved_cart_items to your shopping_cart_items or saved_cart_items
  #   this method is called using AJAX and returns json. with the object moved,
  #   otherwise false is returned if there is an error
  #   method => PUT
  def move_to
    @cart_item = session_cart.cart_items.find(params[:id])
    if @cart_item.update_attributes(:item_type_id => params[:item_type_id])
      redirect_to(shopping_cart_items_url() )
    else
      redirect_to(shopping_cart_items_url(), :notice => I18n.t('item_failed_update') )
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.xml
  def destroy
    session_cart.remove_variant(params[:variant_id]) if params[:variant_id]
    respond_to do |format|
      format.js
    end
  end

  private
  def allowed_params
    params.require(:cart).permit!
  end

end
