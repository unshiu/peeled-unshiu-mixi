module ManageMixiInflowMastersModule

  def editable_master
    if @mixi_inflow_master.id == MixiInflowMaster::TOTAL || @mixi_inflow_master.id == MixiInflowMaster::OTHER
      false
    else
      true
    end
  end

  alias deletable_master editable_master
  alias publish_master editable_master

end