from datetime import datetime

import jinja2
import pdfkit
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from starlette.middleware.cors import CORSMiddleware
from starlette.responses import FileResponse
import logging

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Разрешаем доступ со всех доменов (это не безопасно в реальном применении)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Item(BaseModel):
    name: str
    subtotal: float


# Создаем логгер
logger = logging.getLogger(__name__)


@app.post("/generate_pdf/")
async def generate_pdf_from_json_file(data: dict):
    try:
        client_name = data.get("client_name")
        items_data = data.get("items")

        if not client_name or not items_data:
            raise HTTPException(status_code=400, detail="Missing client_name or items in JSON data")

        items = [Item(**item) for item in items_data]

        today_date = datetime.today().strftime("%d %b, %Y")
        month = datetime.today().strftime("%B")

        item_contexts = []
        total = 0
        for idx, item in enumerate(items, start=1):
            total += item.subtotal
            item_contexts.append({
                f'item': item.name,  # Changed from f'item{idx}'
                f'subtotal': f'${item.subtotal:.2f}'  # Changed from f'subtotal{idx}'
            })

        context = {
            'client_name': client_name,
            'today_date': today_date,
            'total': f'${total:.2f}',
            'month': month,
            'items': item_contexts  # Use a list of item contexts
        }

        template_loader = jinja2.FileSystemLoader('./')
        template_env = jinja2.Environment(loader=template_loader)

        html_template = 'invoice.html'
        template = template_env.get_template(html_template)
        output_text = template.render(context)

        config = pdfkit.configuration(wkhtmltopdf='/usr/bin/wkhtmltopdf')
        output_pdf = 'invoice.pdf'
        pdfkit.from_string(output_text, output_pdf, configuration=config, css='invoice.css')

        return FileResponse(output_pdf, media_type='application/pdf', filename='invoice.pdf')
    except Exception as e:
        logger.error(f"Failed to generate PDF: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to generate PDF: {str(e)}")


if __name__ == "__main__":
    uvicorn.run("microservice:app", host="0.0.0.0", port=8888, reload=True)
