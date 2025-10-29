/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/testimonial-02.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Testimonial02({ alt, ...rest }: Props) {
  return (
    <img
      src={String(src)}
      alt={alt ?? 'Testimonial 02'}
      loading="lazy"
      decoding="async"
      {...rest}
    />
  );
}
