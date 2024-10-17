# Exception personnalisée pour le test
class TestActionViewTemplateError < ActionView::Template::Error
  def initialize; end # rubocop:disable Lint/MissingSuper
end

describe TemplatedErrorPresenter do
  let(:presenter) { described_class.new(message: message, template_name: template_name, locals: locals) }
  let(:message) { "Une erreur est survenue" }
  let(:template_name) { "erreur_personnalisée" }
  let(:locals) { { detail: "Détails de l'erreur" } }
  let(:view_context) { instance_double("view_context") }

  describe "#to_s" do
    it "retourne le message d'erreur" do
      expect(presenter.to_s).to eq(message)
    end
  end

  describe "#partial_path" do
    it "génère le chemin correct pour le partial" do
      expect(presenter.partial_path).to eq("custom_errors/#{template_name}")
    end
  end

  describe "#render" do
    context "quand le template existe" do
      it "rend le template avec les locals fournis" do
        allow(view_context).to receive(:render).with(presenter.partial_path, **locals).and_return("Contenu du template")
        expect(presenter.render(view_context)).to eq("Contenu du template")
      end
    end

    context "quand le template est manquant" do
      before do
        exception = ActionView::MissingTemplate.new([], [], false, {}, "")
        allow(view_context).to receive(:render).and_raise(exception)
        allow(view_context).to receive(:content_tag).with(:p, message).and_return("<p>#{message}</p>")
        allow(Sentry).to receive(:capture_exception)
      end

      it "rend un message par défaut et capture l'exception" do
        expect(presenter.render(view_context)).to eq("<p>#{message}</p>")
        expect(Sentry).to have_received(:capture_exception).with(instance_of(ActionView::MissingTemplate))
      end
    end

    context "quand le template a une erreur" do
      before do
        allow(view_context).to receive(:render).and_raise(TestActionViewTemplateError.new)
        allow(view_context).to receive(:content_tag).with(:p, message).and_return("<p>#{message}</p>")
        allow(Sentry).to receive(:capture_exception)
      end

      it "rend un message par défaut et capture l'exception" do
        expect(presenter.render(view_context)).to eq("<p>#{message}</p>")
        expect(Sentry).to have_received(:capture_exception).with(instance_of(TestActionViewTemplateError))
      end
    end
  end
end
