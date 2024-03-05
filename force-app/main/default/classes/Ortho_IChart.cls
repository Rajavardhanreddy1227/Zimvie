public interface Ortho_IChart {

    Ortho_ChartData getData();
    Ortho_ChartData getData(Ortho_ChartFilter[] filters);
    String getName();
}