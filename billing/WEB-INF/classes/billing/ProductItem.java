package billing;
import java.math.BigDecimal;
//dont delete
public class ProductItem {
    public int productId;
    public BigDecimal qty;
    public double price;
    public double discount;
    public double total;
    public int gst;
    public double cost;
    public double commission;
    public String displayUnit;

    public ProductItem(int productId, BigDecimal qty, double price, double discount, double total, int gst, double cost) {
        this(productId, qty, price, discount, total, gst, cost, 0.0, null);
    }

    public ProductItem(int productId, BigDecimal qty, double price, double discount, double total, int gst, double cost, double commission) {
        this(productId, qty, price, discount, total, gst, cost, commission, null);
    }

    public ProductItem(int productId, BigDecimal qty, double price, double discount, double total, int gst, double cost, String displayUnit) {
        this(productId, qty, price, discount, total, gst, cost, 0.0, displayUnit);
    }

    public ProductItem(int productId, BigDecimal qty, double price, double discount, double total, int gst, double cost, double commission, String displayUnit) {
        this.productId = productId;
        this.qty = qty;
        this.price = price;
        this.discount = discount;
        this.total = total;
        this.gst = gst;
        this.cost = cost;
        this.commission = commission;
        this.displayUnit = displayUnit;
    }
}
