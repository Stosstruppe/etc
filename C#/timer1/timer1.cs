/*
csc /t:winexe timer1.cs
*/
using System;
using System.Drawing;
using System.Windows.Forms;

class Form1 : Form {
	Font font1;
	Label label1;
	Label label2;
	Timer timer1;
	int mode;
	DateTime start;

	Form1() {
		font1 = new Font("Arial", 16);
		label1 = new Label();
		label2 = new Label();
		timer1 = new Timer();
		mode = 0;

		label1.Location = new Point(100, 0);
		label1.Size = new Size(100, 25);
		label1.Font = font1;
		label1.BorderStyle = BorderStyle.Fixed3D;
		label1.BackColor = Color.White;

		label2.Location = new Point(100, 25);
		label2.Size = new Size(100, 25);
		label2.Font = font1;
		label2.BorderStyle = BorderStyle.Fixed3D;
		label2.MouseClick += new MouseEventHandler(label2_MouseClick);
		label2.BackColor = Color.LightGray;

		timer1.Interval = 1000;
		timer1.Tick += new EventHandler(timer1_Tick);
		timer1.Enabled = true;

		Controls.Add(label1);
		Controls.Add(label2);
		ClientSize = new Size(200, 50);
		FormBorderStyle = FormBorderStyle.FixedSingle;
		MaximizeBox = false;
		Text = "timer1";
	}

	void timer1_Tick(object sender, EventArgs e) {
		DateTime now = DateTime.Now;
		label1.Text = now.ToString("HH:mm:ss");
		switch (mode) {
		case 1:
			TimeSpan ts = now - start;
			label2.Text = ts.ToString(@"hh\:mm\:ss");
			break;
		}
	}

	void label2_MouseClick(object sender, MouseEventArgs e) {
		switch (e.Button) {
		case MouseButtons.Left:
			start = DateTime.Now;
			mode = 1;
			label2.BackColor = Color.FromArgb(0xff, 0xff, 0xc0);
			break;
		case MouseButtons.Right:
			mode = 0;
			label2.BackColor = Color.LightGray;
			label2.Text = "";
			break;
		}
	}

	static void Main() {
		Application.Run(new Form1());
	}
}
