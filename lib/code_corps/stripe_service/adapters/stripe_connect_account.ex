defmodule CodeCorps.StripeService.Adapters.StripeConnectAccountAdapter do
  import CodeCorps.MapUtils, only: [keys_to_string: 1]
  import CodeCorps.StripeService.Util, only: [transform_map: 2]

  @stripe_attributes [
    :business_name, :business_url, :charges_enabled, :country, :default_currency, :details_submitted, :email, :id, :managed,
    :support_email, :support_phone, :support_url, :transfers_enabled
  ]

  @doc """
  Mapping of stripe record attributes to locally stored attributes
  Format is {:local_key, [:nesting, :of, :stripe, :keys]}
  """
  @stripe_mapping [
    {:id_from_stripe, [:id]},
    {:business_name, [:business_name]},
    {:business_url, [:business_url]},
    {:charges_enabled, [:charges_enabled]},
    {:country, [:country]},
    {:default_currency, [:default_currency]},
    {:details_submitted, [:details_submitted]},
    {:display_name, [:display_name]},
    {:email, [:email]},
    {:legal_entity_address_city, [:legal_entity, :address, :city]},
    {:legal_entity_address_country, [:legal_entity, :address, :country]},
    {:legal_entity_address_line1, [:legal_entity, :address, :line1]},
    {:legal_entity_address_line2, [:legal_entity, :address, :line2]},
    {:legal_entity_address_postal_code, [:legal_entity, :address, :postal_code]},
    {:legal_entity_address_state, [:legal_entity, :address, :state]},
    {:legal_entity_business_name, [:legal_entity, :business_name]},
    {:legal_entity_business_tax_id_provided, [:legal_entity, :business_tax_id_provided]},
    {:legal_entity_business_vat_id_provided, [:legal_entity, :business_vat_id_provided]},
    {:legal_entity_dob_day, [:legal_entity, :dob, :day]},
    {:legal_entity_dob_month, [:legal_entity, :dob, :month]},
    {:legal_entity_dob_year, [:legal_entity, :dob, :year]},
    {:legal_entity_first_name, [:legal_entity, :first_name]},
    {:legal_entity_last_name, [:legal_entity, :last_name]},
    {:legal_entity_gender, [:legal_entity, :gender]},
    {:legal_entity_maiden_name, [:legal_entity, :maiden_name]},
    {:legal_entity_personal_address_city, [:legal_entity, :personal_address, :city]},
    {:legal_entity_personal_address_country, [:legal_entity, :personal_address, :country]},
    {:legal_entity_personal_address_line1, [:legal_entity, :personal_address, :line1]},
    {:legal_entity_personal_address_line2, [:legal_entity, :personal_address, :line2]},
    {:legal_entity_personal_address_postal_code, [:legal_entity, :personal_address, :postal_code]},
    {:legal_entity_personal_address_state, [:legal_entity, :personal_address, :state]},
    {:legal_entity_phone_number, [:legal_entity, :phone_number]},
    {:legal_entity_personal_id_number_provided, [:legal_entity, :personal_id_number_provided]},
    {:legal_entity_ssn_last_4_provided, [:legal_entity, :ssn_last_4_provided]},
    {:legal_entity_type, [:legal_entity, :type]},
    {:managed, [:managed]},
    {:support_email, [:support_email]},
    {:support_phone, [:support_phone]},
    {:support_url, [:support_url]},
    {:transfers_enabled, [:transfers_enabled]},
    {:verification_disabled_reason, [:verification, :disabled_reason]},
    {:verification_due_by, [:verification, :due_by]},
    {:verification_fields_needed, [:verification, :fields_needed]}
  ]

  @doc """
  Transforms a `%Stripe.Account{}` and a set of local attributes into a
  map of parameters used to create or update a `StripeConnectAccount` record.
  """
  def to_params(%Stripe.Account{} = stripe_account, %{} = attributes) do
    result =
      stripe_account
      |> Map.from_struct
      |> transform_map(@stripe_mapping)
      |> keys_to_string
      |> add_non_stripe_attributes(attributes)

    {:ok, result}
  end

  # Names of attributes which we need to store localy,
  # but are not part of the Stripe API record
  @non_stripe_attributes ["organization_id"]

  defp add_non_stripe_attributes(%{} = params, %{} = attributes) do
    attributes
    |> get_non_stripe_attributes
    |> add_to(params)
  end

  defp get_non_stripe_attributes(%{} = attributes) do
    attributes
    |> Map.take(@non_stripe_attributes)
  end

  defp add_to(%{} = attributes, %{} = params) do
    params
    |> Map.merge(attributes)
  end
end
