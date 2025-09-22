defmodule MyBeliaWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component
  use Gettext, backend: MyBeliaWeb.Gettext

  alias Phoenix.LiveView.JS

  # Routes generation with the ~p sigil
  use Phoenix.VerifiedRoutes,
    endpoint: MyBeliaWeb.Endpoint,
    router: MyBeliaWeb.Router,
    statics: MyBeliaWeb.static_paths()

  @doc """
  Converts document type to Bahasa Malaysia label.
  """
  def get_document_label(doc_type) do
    case doc_type do
      # General docs
      "ic" -> "Salinan Kad Pengenalan"
      "birth" -> "Salinan Surat Beranak"
      "father_ic" -> "Salinan Kad Pengenalan Bapa"
      "mother_ic" -> "Salinan Kad Pengenalan Ibu"
      "resume" -> "Resume"
      "cover_letter" -> "Surat Iringan"
      "support_letter" -> "Surat Iringan Sokongan"
      "education_cert" -> "Sijil-sijil Pendidikan"
      "activity_cert" -> "Sijil-sijil Aktiviti Luar"
      # Grant docs
      "lesen_organisasi" -> "Lesen Organisasi"
      "profil_organisasi" -> "Profil Organisasi"
      "surat_kebenaran" -> "Surat Kebenaran"
      "rancangan_atur_cara" -> "Rancangan Atur Cara"
      "sijil_pengiktirafan" -> "Sijil Pengiktirafan"
      "surat_rujukan" -> "Surat Rujukan"
      "surat_sokongan" -> "Surat Sokongan"
      "proposal" -> "Proposal"
      _ -> doc_type
    end
  end

  @doc """
  Status options for application status changes.
  """
  def status_options do
    [
      {"menunggu", "Menunggu"},
      {"diluluskan", "Lulus"},
      {"ditolak", "Tolak"},
      {"tidak_lengkap", "Tidak Lengkap"}
    ]
  end

  @doc """
  Converts status value to Bahasa Malaysia display text.
  """
  def get_status_label(status) do
    case status do
      "menunggu" -> "Menunggu"
      "pending" -> "Menunggu"
      "diluluskan" -> "Lulus"
      "ditolak" -> "Tolak"
      "tidak_lengkap" -> "Tidak Lengkap"
      nil -> "Menunggu"
      _ -> status
    end
  end

  @doc """
  Status dropdown component for application status changes.
  """
  attr :id, :string, required: true
  attr :application_id, :string, required: true
  attr :current_status, :string, required: true
  attr :show, :boolean, default: false

  def status_dropdown(assigns) do
    ~H"""
    <div class="relative">
      <button
        type="button"
        class="action-btn-small more"
        title="Lain-lain"
        phx-click={JS.toggle(to: "##{@id}")}
      >
        ⋯
      </button>

      <div
        id={@id}
        class={"absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-50 border border-gray-200 #{if @show, do: "block", else: "hidden"}"}
        phx-click-away={JS.hide(to: "##{@id}")}
      >
        <div class="py-1">
          <%= for {status_value, status_label} <- status_options() do %>
            <%= if status_value != @current_status do %>
              <button
                type="button"
                class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-gray-900 border-b border-gray-100 last:border-b-0"
                phx-click={JS.push("select-new-status", value: %{application_id: @application_id, new_status: status_value})}
              >
                Ubah kepada: <%= status_label %>
              </button>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Status confirmation modal for application status changes.
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :application_id, :string, required: true
  attr :current_status, :string, required: true
  attr :new_status, :string, required: true
  attr :on_confirm, JS, required: true
  attr :on_cancel, JS, required: true

  def status_confirmation_modal(assigns) do
    ~H"""
    <%= if @show do %>
      <div
        id={@id}
        class="fixed inset-0 z-50 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
      >
        <!-- Background overlay -->
        <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity"></div>

        <!-- Modal content -->
        <div class="flex min-h-full items-center justify-center p-4">
          <div class="relative w-full max-w-md bg-white rounded-lg shadow-xl">
            <!-- Modal header -->
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">
                Ubah Status Permohonan
              </h3>
            </div>

            <!-- Modal body -->
            <div class="px-6 py-4">
              <p class="text-sm text-gray-600 mb-4">
                Adakah anda pasti mahu mengubah status permohonan ini?
              </p>

              <div class="bg-gray-50 rounded-lg p-4 mb-6">
                <div class="flex items-center justify-center space-x-3 text-sm">
                  <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full">
                    <%= get_status_label(@current_status) %>
                  </span>
                  <span class="text-gray-400">→</span>
                  <span class="px-3 py-1 bg-green-100 text-green-800 rounded-full">
                    <%= get_status_label(@new_status) %>
                  </span>
                </div>
              </div>
            </div>

            <!-- Modal footer -->
            <div class="px-6 py-4 border-t border-gray-200 flex space-x-3">
              <button
                type="button"
                class="flex-1 bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 transition-colors"
                phx-click={@on_confirm}
              >
                Ya, Ubah Status
              </button>
              <button
                type="button"
                class="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-500 transition-colors"
                phx-click={@on_cancel}
              >
                Batal
              </button>
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end



  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-zinc-50/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="shadow-zinc-700/10 ring-zinc-700/10 relative hidden rounded-2xl bg-white p-14 shadow-lg ring-1 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                {render_slot(@inner_block)}
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 mr-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        {@title}
      </p>
      <p class="mt-2 text-sm leading-5">{msg}</p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the data structure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-10 space-y-8 bg-white">
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        {@label}
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div>
      <.label for={@id}>{@label}</.label>
      <select
        id={@id}
        name={@name}
        class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div>
      <.label for={@id}>{@label}</.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 min-h-[6rem]",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div>
      <.label for={@id}>{@label}</.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] mt-11 sm:w-full">
        <thead class="text-sm text-left leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal">{col[:label]}</th>
            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only">{gettext("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  {render_slot(col, @row_item.(row))}
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  {render_slot(action, @row_item.(row))}
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500">{item.title}</dt>
          <dd class="text-zinc-700">{render_slot(item)}</dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        {render_slot(@inner_block)}
      </.link>
    </div>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      time: 300,
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(MyBeliaWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(MyBeliaWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

    @doc """
  Generates dynamic image sizing styles for the homepage logo.

  ## Examples

      <.logo_size width="48" height="48" />
      <.logo_size width="60" height="60" />
  """
  attr :width, :string, default: "48"
  attr :height, :string, default: "48"

  def logo_size(assigns) do
    ~H"""
    <style>
      .brand-left img {
        width: <%= @width %>px !important;
        height: <%= @height %>px !important;
        object-fit: contain !important;
        max-height: none !important;
        position: relative !important;
        z-index: 999 !important;
      }
    </style>
    """
  end

  @doc """
  Controls the gradient overlay opacity for the hero section.

  ## Examples

      <.hero_overlay opacity="0.8" />
      <.hero_overlay opacity="0.5" />
      <.hero_overlay opacity="0.2" />
  """
  attr :opacity, :string, default: "0.8"

  def hero_overlay(assigns) do
    ~H"""
    <style>
      .hero::before {
        opacity: <%= @opacity %> !important;
      }
    </style>
    """
  end

  @doc """
  Controls the contrast of the hero logo (node-6 image).

  ## Examples

      <.hero_logo_contrast contrast="1.2" />
      <.hero_logo_contrast contrast="0.8" />
      <.hero_logo_contrast contrast="1.5" />
  """
  attr :contrast, :string, default: "1.0"

  def hero_logo_contrast(assigns) do
    ~H"""
    <style>
      .hero-logo {
        filter: contrast(<%= @contrast %>) !important;
      }
    </style>
    """
  end

  @doc """
  Controls the size of the hero logo (node-6 image).

  ## Examples

      <.hero_logo_size width="400" height="200" />
      <.hero_logo_size width="500" height="250" />
      <.hero_logo_size width="600" height="300" />
  """
  attr :width, :string, default: "360"
  attr :height, :string, default: "auto"

  def hero_logo_size(assigns) do
    ~H"""
    <style>
      .hero-logo {
        width: <%= @width %>px !important;
        height: <%= @height %>px !important;
        max-width: 90% !important;
      }
    </style>
    """
  end

  @doc """
  Controls the social media icon sizes and positioning.

  ## Examples

      <.social_icon_size ellipse_size="40" image_size="24" />
      <.social_icon_size ellipse_size="50" image_size="30" />
      <.social_icon_size ellipse_size="35" image_size="20" />
  """
  attr :ellipse_size, :string, default: "40"
  attr :image_size, :string, default: "24"

  def social_icon_size(assigns) do
    ~H"""
    <style>
      .social-icon-container {
        width: <%= @ellipse_size %>px !important;
        height: <%= @ellipse_size %>px !important;
      }

      .social-ellipse {
        width: <%= @ellipse_size %>px !important;
        height: <%= @ellipse_size %>px !important;
      }

      .social-image {
        width: <%= @image_size %>px !important;
        height: <%= @image_size %>px !important;
      }
    </style>
    """
  end

  @doc """
  Controls the agency logo sizes in the footer.

  ## Examples

      <.agency_logo_size width="80" height="80" />
      <.agency_logo_size width="100" height="100" />
      <.agency_logo_size width="60" height="60" />
  """
  attr :width, :string, default: "80"
  attr :height, :string, default: "80"

  def agency_logo_size(assigns) do
    ~H"""
    <style>
      .agency-logo {
        width: <%= @width %>px !important;
        height: <%= @height %>px !important;
        object-fit: contain !important;
      }
    </style>
    """
  end

  @doc """
  Controls the admin logo size in the sidebar.

  ## Examples

      <.admin_logo_size width="40" height="40" />
      <.admin_logo_size width="60" height="60" />
      <.admin_logo_size width="80" height="80" />
  """
  attr :width, :string, default: "40"
  attr :height, :string, default: "40"

  def admin_logo_size(assigns) do
    ~H"""
    <img src={~p"/images/node-17.png"} alt="MyBelia Logo" class="admin-logo" />
    <style>
      .admin-logo {
        width: <%= @width %>px !important;
        height: <%= @height %>px !important;
        object-fit: contain !important;
      }
    </style>
    """
  end

  @doc """
  Renders a reusable admin sidebar component.

  ## Examples

      <.admin_sidebar current_page="permohonan_geran" />
      <.admin_sidebar current_page="program" />
      <.admin_sidebar current_page="kursus" />
  """
  attr :current_page, :string, default: "dashboard"
  attr :logo_width, :string, default: "160"
  attr :logo_height, :string, default: "120"

  def admin_sidebar(assigns) do
    ~H"""
    <div class="sidebar">
      <div class="sidebar-header">
        <a href="/laman-utama-pengguna" class="admin-logo-link">
          <.admin_logo_size width={@logo_width} height={@logo_height} />
        </a>
      </div>

      <div class="sidebar-section">
        <h3 class="section-title">UTAMA</h3>
        <ul class="nav-list">
          <li><a href="/admin" class={"nav-link #{if @current_page == "dashboard", do: "active"}"}>Dashboard</a></li>
          <li><a href="/senarai_admin" class={"nav-link #{if @current_page == "admin", do: "active"}"}>Admin</a></li>
          <li><a href="/admin" class={"nav-link #{if @current_page == "tetapan", do: "active"}"}>Tetapan</a></li>
          <li class="dropdown-item">
            <a href="#" class="nav-link dropdown-toggle" data-dropdown="permohonan-utama">Permohonan</a>
            <ul class="dropdown-menu" id="permohonan-utama">
              <li><a href="/admin/permohonan_program" class={"nav-link #{if @current_page == "permohonan_program", do: "active"}"}>Program</a></li>
              <li><a href="/admin/permohonan_kursus" class={"nav-link #{if @current_page == "permohonan_kursus", do: "active"}"}>Kursus</a></li>
              <li><a href="/admin/permohonan_geran" class={"nav-link #{if @current_page == "permohonan_geran", do: "active"}"}>Geran</a></li>
            </ul>
          </li>
          <li><a href="/admin" class={"nav-link #{if @current_page == "galeri", do: "active"}"}>Galeri</a></li>
        </ul>
      </div>

      <div class="sidebar-section">
        <h3 class="section-title">SISTEM</h3>
        <ul class="nav-list">
                <li class="dropdown-item">
        <a href="#" class={"nav-link dropdown-toggle #{if @current_page == "laporan_program" or @current_page == "laporan_kursus", do: "active"}"} data-dropdown="laporan-sistem">Laporan</a>
        <ul class={"dropdown-menu #{if @current_page == "laporan_program" or @current_page == "laporan_kursus", do: "show"}"} id="laporan-sistem">
          <li><a href="/laporan_program" class={"nav-link #{if @current_page == "laporan_program", do: "active"}"}>Program</a></li>
          <li><a href="/laporan_kursus" class={"nav-link #{if @current_page == "laporan_kursus", do: "active"}"}>Kursus</a></li>
          <li><a href="/admin" class="nav-link">Geran</a></li>
        </ul>
      </li>

          <li><a href="/admin" class={"nav-link #{if @current_page == "khidmat", do: "active"}"}>Khidmat Pengguna</a></li>
        </ul>
      </div>

      <!-- Logout Section -->
      <div class="sidebar-section logout-section">
        <ul class="nav-list">
          <li><a href="/log-keluar" class="nav-link logout-link">Log Keluar</a></li>
        </ul>
      </div>
    </div>
    """
  end

  @doc """
  Renders the admin page header with menu toggle and user profile.

  ## Examples

      <.admin_header page_title="Permohonan Geran" />
      <.admin_header page_title="Program Management" />
  """
  attr :page_title, :string, required: true

  def admin_header(assigns) do
    ~H"""
    <div class="top-header">
      <div class="menu-icon" id="menu-toggle">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="3" y1="6" x2="21" y2="6"></line>
          <line x1="3" y1="12" x2="21" y2="12"></line>
          <line x1="3" y1="18" x2="21" y2="18"></line>
        </svg>
      </div>
      <h1 class="page-title"><%= @page_title %></h1>
      <div class="user-profile">
        <img src={~p"/images/0b9a9b81d3a113f1a70cb1cdc85b2d2d.jpg"} alt="Profile" class="profile-icon" />
      </div>
    </div>
    """
  end

  @doc """
  Renders the admin page container with sidebar and main content.

  ## Examples

      <.admin_layout current_page="permohonan_geran" page_title="Permohonan Geran">
        <div>Your content here</div>
      </.admin_layout>
  """
  attr :current_page, :string, default: "dashboard"
  attr :page_title, :string, required: true
  slot :inner_block, required: true

  def admin_layout(assigns) do
    ~H"""
    <div class="admin-container">
      <.admin_sidebar current_page={@current_page} />

      <div class="main-content">
        <.admin_header page_title={@page_title} />
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
